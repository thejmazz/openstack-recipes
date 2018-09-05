# CoreDNS


```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -u ubuntu --extra-vars @vars.yml --ssh-extra-args="-J ubuntu@$(osgfip recipe-etcd-bastion)" ./playbooks/coredns.yml
```
