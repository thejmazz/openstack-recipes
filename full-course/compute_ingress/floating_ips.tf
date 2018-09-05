resource "openstack_compute_floatingip_v2" "ingress" {
  pool = "${var.external_network_name}"
}

resource "openstack_compute_floatingip_associate_v2" "ingress" {
  floating_ip = "${openstack_compute_floatingip_v2.ingress.address}"
  instance_id = "${openstack_compute_instance_v2.ingress.id}"
}
