resource "openstack_compute_floatingip_v2" "web" {
  pool = "${var.external_network_name}"
}

resource "openstack_compute_floatingip_associate_v2" "web" {
  floating_ip = "${openstack_compute_floatingip_v2.web.address}"
  instance_id = "${openstack_compute_instance_v2.web.id}"
}
