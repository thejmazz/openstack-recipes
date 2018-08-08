output "public_name" {
  value = "${openstack_networking_network_v2.public.name}"
}

output "private_name" {
  value = "${openstack_networking_network_v2.private.name}"
}

output "airgap_name" {
  value = "${openstack_networking_network_v2.airgap.name}"
}
