// Public
resource "openstack_networking_router_interface_v2" "public" {
  router_id = "${openstack_networking_router_v2.public.id}"
  subnet_id = "${openstack_networking_subnet_v2.public.id}"
}

// DNS
resource "openstack_networking_router_interface_v2" "privete_dns" {
  router_id = "${openstack_networking_router_v2.private.id}"
  subnet_id = "${openstack_networking_subnet_v2.dns.id}"
}

resource "openstack_networking_router_interface_v2" "private_port_public_gateway_private" {
  router_id = "${openstack_networking_router_v2.private.id}"
  port_id = "${openstack_networking_port_v2.public_gateway_private.id}"
}

// Airgap
/* resource "openstack_networking_router_interface_v2" "airgap" { */
/*   router_id = "${openstack_networking_router_v2.airgap.id}" */
/*   subnet_id = "${openstack_networking_subnet_v2.airgap.id}" */
/* } */

resource "openstack_networking_router_interface_v2" "private_port_public_gateway_airgap" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  port_id = "${openstack_networking_port_v2.public_gateway_airgap.id}"
}
