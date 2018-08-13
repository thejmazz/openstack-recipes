resource "openstack_networking_network_v2" "private" {
  name = "${var.project_name}_private"
}

resource "openstack_networking_subnet_v2" "private" {
  network_id = "${openstack_networking_network_v2.private.id}"
  name = "${openstack_networking_network_v2.private.name}"

  subnetpool_id = "${openstack_networking_subnetpool_v2.private.id}"
}

resource "openstack_networking_router_interface_v2" "private" {
  router_id = "${openstack_networking_router_v2.private.id}"
  subnet_id = "${openstack_networking_subnet_v2.private.id}"
}
