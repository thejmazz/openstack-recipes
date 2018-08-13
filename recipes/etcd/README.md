# etcd

```
terraform plan/apply -target=module.networking
# Wait a little for interfaces on routers to be ready (down -> build -> active)
terraform plan/apply -target=module.compute

terraform-inventory --inventory > hosts
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -u ubuntu -T 30 --extra-vars @initialize-rootca.vars.yml --ssh-extra-args="-J ubuntu@$(terraform output bastion_fip)" ./playbooks/initialize-rootca.yml


ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -u ubuntu --extra-vars @initialize-rootca.vars.yml --ssh-extra-args="-J ubuntu@$(terraform output bastion_fip)" ./playbooks/etcd.yml
```

Test it works:

```
docker run --rm -it -e ETCDCTL_API=3 -e ETCDCTL_ENDPOINTS=http://10.210.0.10:2379,http://10.210.0.11:2379,http://10.210.0.12:2379 gcr.io/etcd-development/etcd:v3.3.9 sh
$ etcdctl member list
$ etcdctl -w table endpoint status
$ etcdctl put foo bar
$ etcdctl get foo
```
