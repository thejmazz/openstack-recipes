# Rancher Kubernetes Engine

Note there is
[terraform-provider-rke](https://github.com/yamamoto-febc/terraform-provider-rke)
which can help to dynamically create a `cluster.yml` for RKE. However here we
set up a remote node to store the config (which is not too difficult to
dynamically render via Ansible either). That being said, the RKE provider has a
nice set of [outputs][outputs] like `cluster.api_server_url`,
`cluster.kube_config_yaml`, etc. Be aware if you do choose to use
terraform-provider-rke, some of these properties are sensitive values and will
be stored in terraform state. When things go wrong, you will need to debug
through 2 layers of tooling. The "terraform for everything" approach is not for
everyone. Here, instead I use the terraform + Ansible approach.

[outputs]:= https://github.com/yamamoto-febc/terraform-provider-rke/blob/8870decf5c230536941f9b65a85183c577b7e2a9/rke/resource_rke_cluster.go#L31

I think it is simpler to control our own `cluster.yml` rather than wrapping it
up in a terraform provider. In addition RKE is undergoing development and it
would be unfurtunate to have to wait on terraform-provider-rke to catch up.
However it does mean we *should* use Ansible, (or else, do everything manually).

See the [RKE Docs](https://rancher.com/docs/rke/v0.1.x/en/).

Follow these instructions to deploy a Kubernetes cluster using RKE, deploy an
IngressController and stateless app to it (the backup/restore of stateful apps
running within K8s itself is NOT demonstrated here), then run some backup and
restore procedures.

- [x] single stacked master failure
- [ ] single controller failure
- [ ] single etcd failure
- [ ] multiple etcd failure
- [ ] multiple controllers failure
- [ ] multiple controllers and etcd nodes failures (only workers left)
- [ ] cluster completely destroyed

This recipe was written using RKE v0.1.8.

It deploys

- A public and private network
- A bastion host with a public IP (which also runs HAProxy)
- A `rke_controller` host, not to be confused with K8s controlplane nodes
- Alternative sets of controlplane, etcd, and worker nodes, depending on the example scenario

```bash
terraform init

# Networking
terraform plan/apply -target=module.networking

# Instances
terraform plan/apply -target=module.compute

# Ansible
terraform-inventory --inventory > hosts
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -u ubuntu --ssh-extra-args="-J ubuntu@$(terraform output bastion_ip)" playbook.yml
```

SSH into controller. Then

```bash
rke config
rke up
mkdir ~/.kube && cp kube_config_cluster.yml ~/.kube/config
kubectl get nodes
kubectl -n kube-system get pods

# Deploy an app
kubectl run whoami --image=emilevauge/whoami --replicas=2
kubectl expose deployment whoami --port=80 --target-port=80
cat | kubectl apply -f - <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: whoami
  namespace: default
spec:
  rules:https://github.com/yamamoto-febc/terraform-provider-rke
  - host: whoami.local
    http:
      paths:
      - backend:
          serviceName: whoami
          servicePort: 80
EOF

# On a worker node, can use localhost. Else use the IP of HAProxy.
curl -H "Host: whoami.local" http://localhost/

# Back on the controller, lets make a backup:
rke etcd snapshot-save
# This puts a PKI bundle and etcd snapshot under /opt/rke/etcd-snapshots on each node with 'etcd' role
# Copy it to the controller, something like:
rsync -avP ubuntu@10.50.0.7:/opt/rke/etcd-snapshots/rke_etcd_snapshot_2018-08-05T15\:48\:17Z ./rke_etcd_snapshot_2018-08-05T15\:48\:17Z
# Copy pki.bundle.tar.gz as well

# Now, simulate a failure by tainting the master with terraform:
terraform taint openstack_compute_instance_v2.master
terraform plan/apply
# Notice whoami is still running, but kubectl commands now fail

# Prepare new node for restore
# SSH into the new master
# etcd-snapshot and pki bundle
sudo mkdir -p /opt/rke/etc-snapshots
(s)cp pki.bundle.tar.gz /opt/rke/etcd-snapshots/
(s)cp rke_etcd_snapshot_date /opt/rke/etcd-snapshots/rke_etcd_snapshot_date
# K8s PKI
sudo mkdir -p /etc/kubernetes/ssl

# This was so etcd could find its certs - happened to be same IP though
# Don't need to do this. Let the etcd fail w/o finding its certs until `rke up` is ran
# sudo tar xzfv pki.bundle.tar.gz --strip-components=3 -C /etc/kubernetes/ssl

# Back on controller, update cluster.yml to point to new etcd node and
rke etcd snapshot-restore --name rke_etcd_snapshot_2018-08-05T15\:48\:17Z

# After etcd restored, we can bring up controlplane, (or point existing controlplane nodes to new etcd)
rke up

# Check it was successfull, should display whoami pods
kubectl get pods
```

## Deploy a Workload

We need something running to check if the etcd restore is successfull. Note
that RKE deploys an nginx ingress controller to each worker node with
`hostNetwork: true` which is why we can now simply expose the `whoami` service
via an `Ingress`.

```bash
kubectl --kubeconfig kube_config_cluster.yml run whoami --image=emilevauge/whoami --replicas=2
kubectl --kubeconfig kube_config_cluster.yml expose deployment whoami --port=80 --target-port=80
cat | kubectl --kubeconfig kube_config_cluster.yml apply -f - <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: whoami
  namespace: default
spec:
  rules:
  - host: whoami.local
    http:
      paths:
      - backend:
          serviceName: whoami
          servicePort: 80
EOF

kubectl --kubeconfig kube_config_cluster.yml get pods
export WORKER_IP=$(kubectl --kubeconfig kube_config_cluster.yml get node rketest-worker-1 -o json | jq -r '.status.addresses[] | select(.type=="InternalIP") | .address')
curl -H "Host: whoami.local" $WORKER_IP
```

## etcd Snapshot

Verify `rke_controller` can reach etcd node(s):

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible -i hosts -u ubuntu -m ping rke_role_etcd
```

From `rke_controller`, create an etcd snapshot on all etcd nodes and keep track
of its name:

```bash
rke etcd snapshot-save
# Or, with an explicit name:
rke etcd snapshot-save --name snapshot.db
```

Now copy the snapshot and the PKI bundle to `rke_controller`:

Using ad-hoc commands:

```bash
export ETCD_SNAPSHOT_NAME=snapshot.db
ANSIBLE_HOST_KEY_CHECKING=False ansible -i hosts -u ubuntu -m fetch -a "src=/opt/rke/etcd-snapshots/$ETCD_SNAPSHOT_NAME dest=./backup/$ETCD_SNAPSHOT_NAME flat=yes" rke_role_etcd
ANSIBLE_HOST_KEY_CHECKING=False ansible -i hosts -u ubuntu -m fetch -a "src=/opt/rke/etcd-snapshots/pki.bundle.tar.gz dest=./backup/pki.bundle.tar.gz flat=yes" rke_role_etcd
```

Or the playbook `snapshot.yml`:

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -u ubuntu --extra-vars "snapshot_name=snapshot.db" snapshot.yml
```

You could just as well manually use `scp` or `rsync`, etc - but will have to
mangle your way around file permissions. Ansible `become`s `root` by default.

## Scenario 3: Loss of Stacked Master

```bash
openstack server delete rketest_master
```

Notice you can still reach `whoami`, but `kubctl` commands now timeout since
the API server is gone:

```
Unable to connect to the server: dial tcp 10.51.0.10:6443: connect: no route to host
```

The services on our cluster will continue running as if nothing happened (from
their perspective, *nothing happened*), we have *just* lost control over
orchestrating them is all. Now lets create a new master node:

```bash
# Launch new node(s)
terraform plan/apply -target=module.compute

# Update inventory
terraform-inventory --inventory > hosts

# Update cluster.yml on rke_controller
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -u ubuntu --ssh-extra-args="-J ubuntu@$(terraform output bastion_ip)" playbook.yml
```

Then ssh into `rke_controller` and prepare the etcd node(s) (copy snapshot and
PKI bundle into `/opt/rke/etcd-snapshots`):

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -u ubuntu --extra-vars "snapshot_name=snapshot.db" restore.yml
```

Then we can restore the etcd node(s):

```bash
rke etcd snapshot-restore --name snapshot.db
```

At this point the etcd node will be stuck in a restart loop as it cannot find
its certificates in `/etc/kubdernetes/ssl`. Follow up by restoring the RKE
cluster state:

```bash
rke up
```

Verify the restore was successfull, you should see the `whoami` pods:

```bash
kubectl --kubeconfig kube_config_cluster.yml get pods
```

## Example Errors

If you `rke up` before `rke etcd snapshot-restore`:

```
FATA[0210] [workerPlane] Failed to bring up Worker Plane: Failed to verify
healthcheck: Service [kubelet] is not healthy on host [10.51.0.13]. Response
code: [401], response body: Unauthorized, log: E0806 17:48:48.738318    3861
reflector.go:205] k8s.io/kubernetes/pkg/kubelet/config/apiserver.go:47: Failed
to list *v1.Pod: Get
https://127.0.0.1:6443/api/v1/pods?fieldSelector=spec.nodeName%3Drketest-worker-1&limit=500&resourceVersion=0:
x509: certificate signed by unknown authority (possibly because of "crypto/rsa:
verification error" while trying to verify candidate authority certificate
"kube-ca")
```

And then even after running the snapshot-restore, since you previously `rke up`
with a "bad" config, cannot reconcile etcd plane:

```
FATA[0016] Failed to reconcile etcd plane: Failed to add etcd member [etcd-rketest-master] to etcd cluster
```

Congratulations, you seem to have borked the cluster. Either dig in manually
and fix up kubelet and others, or deploy a new cluster from scratch, restored
from an etcd snapshot.

## Notes

### Workstation as rke_controller

This is entirely possible, and perhaps preferred under certain scenarios. I
used a separate instance so that software installation could be automated for
the purposes of an easy to follow tutorial. Keep in mind if you do use your
workstation as the controller, you will want to back up `cluster.yml` somewhere
safe. One benefit of using a remote machine as the controller is that
`known_hosts` could be automated there, software versions can be locked, it can
be used as backup node with a local cron job, and anyone with ssh access can
play with `rke`.

### Host Key Checking

Why all the `ANSIBLE_HOST_KEY_CHECKING=False`? To get around this we can either

1. "Prepare the `~/.ssh/known_hosts`" by first manually `ssh`ing into each machine and entering `yes`
2. Enter `yes` when running ansible (YMMV if playbook runs across multiple hosts)
3. Grab the ECDSA public key of each host from a trusted source and prepare `known_hosts` ahead of time

Options (1) and (2) are in direct opposition to our goal of declarative,
immutable infrastructure.

Option (3) is the best but requires storing VM console logs in a centralized
location. The scope of this is beyond this tutorial, however ELK stack with a
custom forwarder for `openstack console log <server_name>` is a good solution.

### Backups Location

It would make more sense to store the backups in a dedicated location within
the OpenStack project which is itself synchronized offsite. Minio comes to
mind. However, it becomes annoying to handle `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` credentials either manually, or even with Ansible +
Ansible Vault. The ideal way is using Hashicorp Vault, then machines can use a
policy to grab credentials when required, and we do not leave credentials
hanging around anywhere. This means we need Minio, Vault, and a backend for
Vault such as etcd, deployed outside the Kubernetes cluster (or in another
cluster!?). The scope of this is beyond this tutorial, whose purpose is to
demonstrate backup + restore of RKE clusters.

### Value of HA

Running etcd with 3 or 5 nodes enables two properties of your cluster:

1. Quicker restore of state when a node goes down (limited by Raft election process)
2. Redundancy of etcd hosts

Property (1) is really not that important. It is unlikely you will be modifying
the cluster state so often that this is worth the investment. However, property
(2) can be valuable because it means you can confidently recycle or restart
servers. Another approach, which is perhaps a nice in-between, is to manage the
lifecycle of a block device storing etcd state outside the lifecycle of a
single etcd nodes, which may come and go.

### RKE vs Other Kubernetes Installers

*In the context of a self-hosted, potentially ran on OpenStack, situation.*

RKE vs Kubeadm. Kubeadm is the upstream tooling, with it you will get latest
features (like CoreDNS) and most flexibility with networking plugins. However,
upgrading and repairing broken clusters will be more difficult and requires
stronger understanding of the individual components, managing your own PKI,
etc. `rke up` is smart enough to reconcile cluster to state to point to new
etcd node(s), or generate/recover SSL certificates for the Kubernetes
components - this is not to be understated.

RKE vs Kubespray. Kubespray is a gigantic Ansible playbook. It is a reasonable
option to choose if are familiar with Ansible and willing to dig into the tasks
if something goes wrong.  However RKE also supports HA and is simpler (a single
binary and single source of truth `cluster.yml`). Kubespray uses Vault as a
PKI.

RKE vs Kops. Kops does not work on OpenStack (atm, it is only GA on AWS).

## References

- [RKE Backups and Disaster Recovery](https://rancher.com/docs/rke/v0.1.x/en/installation/etcd-snapshots/)
- [Recover Rancher Kubernetes cluster from a Backup](https://rancher.com/blog/2018/recover-rancher-kubernetes-cluster-from-backup/)
- [rancher/rke Backup etcd 456](https://github.com/rancher/rke/issues/456)
- [Rancher 2 HA Restore](https://rancher.com/docs/rancher/v2.x/en/backups/restorations/ha-restoration/)
- [Backup and Restore a Kubernetes Master with Kubeadm](https://labs.consol.de/kubernetes/2018/05/25/kubeadm-backup.html)
- [Cluster @%#’d – How to Recover a Broken Kubernetes Cluster](https://codefresh.io/kubernetes-tutorial/recover-broken-kubernetes-cluster/)
- [Use jq to get the external IP of Kubernetes Nodes](https://anthonysterling.com/posts/use-jq-to-get-the-external-ip-of-kubernetes-nodes.html)
