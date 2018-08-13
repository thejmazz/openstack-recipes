output "public_floating_ip" {
  value = "${openstack_compute_floatingip_v2.public.address}"
}

output "private_local_ip" {
  value = "${openstack_compute_instance_v2.private.access_ip_v4}"
}
