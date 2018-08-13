// Private
resource "openstack_networking_router_interface_v2" "private_port_public_gateway_private" {
  router_id = "${openstack_networking_router_v2.private.id}"
  port_id = "${openstack_networking_port_v2.public_gateway_private.id}"
}

// Airgap
resource "openstack_networking_router_interface_v2" "private_port_public_gateway_airgap" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  port_id = "${openstack_networking_port_v2.public_gateway_airgap.id}"
}
