resource "openstack_compute_floatingip_v2" "controller" {
  pool = "${var.external_network_name}"
}

resource "openstack_compute_floatingip_associate_v2" "controller" {
  floating_ip = "${openstack_compute_floatingip_v2.controller.address}"
  instance_id = "${openstack_compute_instance_v2.controller.id}"
}
