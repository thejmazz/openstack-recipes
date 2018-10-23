# Networking

The following resources are used to construct your "virtual private cloud" (VPC)
in OpenStack:

- networks and subnets (typically one-to-one)
- routers
- external gateways
- interfaces
- router static routes
- subnet routes

The most minimal functional setup would be

- single router with external gateway set to external network
- single network with corresponding subnet, has default interface on router

This is available as the [public][networking-public] module.

[networking-public]: https://github.com/CanDIG/infrastructure/tree/master/tf-modules/openstack/networking/public

## Advanced

For a more secure networking setup, you would like to separate VMs by their
public internet egress access, certain ingress access only from specific CIDRs
(like for a local network), etc. These choices will depend strongly on the
security requirements of the specific premises.

In the [public-private-airgap][networking-public-private-airgap] module is a
networking setup which has 3 networks:

- public, can have floating IPs associated with instances, instances have
  egress access to public internet via default gateway
- private, cannot have floating IPs associated, instances have egress access to
  public internet via routing rules on the router which send packets to the
  default gateway of the public router
- airgap, cannot have floating IPs associated, do not have any egress access to
  the public internet (but could via a proxy in the other networks)
- instances within in each network can communicate with instances in all other networks

Following the principle of least access, you should try to run everything
except the edge router within the airgap network, however this complicates
deployment by requiring that you host an internal Docker registry, for example.
Furthermore airgap instances cannot install packages via the operating systems
package manager, so must be built ahead of time.

One use case for the airgap network is for the root certificate authority for
your primary key infrastructure (PKI). This way, you can be confident the root
CAs private key cannot be leaked out via a public link. But operators with
access to the VM could still log in and copy it out, in which case you want to
disable SSH on the VM. By utilizing immutable infrastructure practices and only
allowing network access to the CFSSL multirootca server, we can be fairly
confident the root CA private key will not be compromised.

[networking-public-private-airgap]: https://github.com/CanDIG/infrastructure/tree/master/tf-modules/openstack/networking/public-private-airgap
