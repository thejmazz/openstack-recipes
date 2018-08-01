# Public and Private Networks

```bash
terraform init
# Edit terraform.tfvars as per variables.tf, or use -var "key=val", or set TF_VAR_key, or enter values at the prompt
terraform plan
terraform apply
```

Note, the interfaces attached to the routers may take ~30s or so to become UP
and active.

Once you have deployed the infrastructure, you should be able to log into the
private box via the public host:

```bash
ssh ubuntu@$(terraform output private_local_ip) -J ubuntu@$(terraform output public_floating_ip)
```

If that works, instances on the public and private networks can communicate
with each other.

From the private instance you can successfully resolve names since you are
using the public network's DNS:

```
GOOGLE_IP=$(dig +short google.ca)
echo $GOOGLE_IP

# `dig @10.222.0.2 google.ca` will timeout
```

But you cannot communicate with the outside world:

```bash
ping $GOOGLE_IP
```

However, we can add a new route to enable this communication, either whitelist style:

```bash
# From your workstation,
GOOGLE_IP=$(dig +short google.ca)
openstack router set --route destination=$GOOGLE_IP/32,gateway=10.111.0.1 myproject_private
```

Or blanket everyting style (in which case you would not need the
`10.111.0.0/24 -> 10.111.0.1` route anymore as well):

```bash
openstack router set --route destination=0.0.0.0/0,gateway=10.111.0.1 myproject_private
```

Then back inside the private instance:

```bash
$ curl $GOOGLE_IP
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

If its not working, `dig +short google.ca` might be using a new value, try
using exactly the same IP as in the static route.

This is interesting because then you can essentially temporarily toggle access
to the public internet by adding and removing the static route.

You could also add an external gateway to the private router.

## Cleanup

Before running `terraform destroy`, delete any static routes which you manually
created outside of terraform:

- [openstack router set](https://docs.openstack.org/python-openstackclient/pike/cli/command-objects/router.html#router-set)

```bash
# Does not work for me...
openstack router set --no-route --route destination=$GOOGLE_IP/32,gateway=10.111.0.1 myproject_private
# Use Horizon, or clear all routes
openstack router set --no-route myproject_private
```

If static routes exist on the router when trying to delete its (last?)
interface(s?), then the delete will fail (and terraform waits ~10mins before it
gives up).

## References

-  [Why Can't I Ping Across My Tenant Networks?](https://ibm-blue-box-help.github.io/help-documentation/troubleshooting/Unable_to_ping_tenant_network/)
