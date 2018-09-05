resource "openstack_networking_router_v2" "public" {
  external_network_id = "${var.external_network_id}"

  name = "${var.project_name}_public_router"
}

resource "openstack_networking_router_v2" "private" {
  name = "${var.project_name}_private"
}

resource "openstack_networking_router_v2" "airgap" {
  name = "${var.project_name}_airgap"
}
