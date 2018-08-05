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
- A `rke-controller` host, not to be confused with K8s controlplane nodes
- Alternative sets of controlplane, etcd, and worker nodes, depending on the example scenario

```bash
terraform init

# Networking
terraform plan/apply -target=openstack_networking_router_interface_v2.public

# Instances
terraform plan/apply

# Ansible
terraform-inventory --inventory > hosts
ansible-playbook -i hosts -u ubuntu playbook.yml
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

# After etcd restored, we can bring up controlplane, (or point existing C nodes to new etcd)
rke up

# Check it was successfull, should display whoami pods
kubectl get pods
```

## References

- [RKE Backups and Disaster Recovery](https://rancher.com/docs/rke/v0.1.x/en/installation/etcd-snapshots/)
- [Recover Rancher Kubernetes cluster from a Backup](https://rancher.com/blog/2018/recover-rancher-kubernetes-cluster-from-backup/)
- [rancher/rke Backup etcd 456](https://github.com/rancher/rke/issues/456)
- [Rancher 2 HA Restore](https://rancher.com/docs/rancher/v2.x/en/backups/restorations/ha-restoration/)
- [Backup and Restore a Kubernetes Master with Kubeadm](https://labs.consol.de/kubernetes/2018/05/25/kubeadm-backup.html)
