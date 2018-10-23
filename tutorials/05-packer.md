# Packer

Now that we have

- networking
- security groups
- a base image

We can start to use Packer as a tool to manage image creation. We will use it primarily to

- update and upgrade our base image
- install some common utilities like `curl` and `jq`
- install Docker, and prepare the image for specific Docker networking
  considerations (e.g. MTU, docker0 interface CIDR)
- install applications

Note that references to a playbook need to be relative to where you call
`packer` from.

```bash
alias packer="docker-compose run --rm packer"
packer build \
-var "floating_ip_pool=$(openstack network list --external -f value -c Name)" \
-var "network_uuid=$(openstack network list -f json | jq -r '.[] | select(.Name == "my_public_network") | .ID')" \
-var "source=ubuntu_1604_20180912" \
template.json
```

Then use the image created as source for the playbook which sets up Docker.
