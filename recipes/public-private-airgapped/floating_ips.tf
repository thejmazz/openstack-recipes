resource "openstack_compute_floatingip_v2" "public" {
  pool = "${var.external_network_name}"
}

resource "openstack_compute_floatingip_associate_v2" "public" {
  floating_ip = "${openstack_compute_floatingip_v2.public.address}"
  instance_id = "${openstack_compute_instance_v2.public.id}"
}
