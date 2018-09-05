output "network" {
  value = "${openstack_networking_network_v2.coredns.name}"
}

output "subnet" {
  value = "${openstack_networking_subnet_v2.coredns.name}"
}
