output "network_public" {
  value = "${openstack_networking_network_v2.public.name}"
}

output "network_private" {
  value = "${openstack_networking_network_v2.private.name}"
}
