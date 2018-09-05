data "openstack_networking_subnetpool_v2" "private" {
  name = "${var.project_name}_${var.subnetpool}"
}

resource "openstack_networking_network_v2" "coredns" {
  name = "${var.project_name}_coredns"
}

resource "openstack_networking_subnet_v2" "coredns" {
  network_id = "${openstack_networking_network_v2.coredns.id}"
  name = "${openstack_networking_network_v2.coredns.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.private.id}"
}

resource "openstack_networking_router_interface_v2" "private" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.coredns.id}"
}
