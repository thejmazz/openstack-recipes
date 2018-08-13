// Public Router
resource "openstack_networking_router_route_v2" "public_to_private" {
  depends_on = [ "openstack_networking_router_interface_v2.private_port_public_gateway_private" ]

  router_id = "${openstack_networking_router_v2.public.id}"

  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.private.prefixes, 0)}"
  next_hop = "${element(openstack_networking_port_v2.public_gateway_private.all_fixed_ips, 0)}"
}

resource "openstack_networking_router_route_v2" "public_to_airgap" {
  depends_on = [ "openstack_networking_router_interface_v2.private_port_public_gateway_airgap" ]

  router_id = "${openstack_networking_router_v2.public.id}"

  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.airgap.prefixes, 0)}"
  next_hop = "${element(openstack_networking_port_v2.public_gateway_airgap.all_fixed_ips, 0)}"
}

// Private Router
resource "openstack_networking_router_route_v2" "private_to_airgap" {
  depends_on = [ "openstack_networking_router_interface_v2.private_port_public_gateway_private" ]

  router_id = "${openstack_networking_router_v2.private.id}"

  destination_cidr = "0.0.0.0/0"
  next_hop = "${openstack_networking_subnet_v2.public.gateway_ip}"
}

resource "openstack_networking_router_route_v2" "private_to_airgap2" {
  depends_on = [ "openstack_networking_router_interface_v2.private_port_public_gateway_private" ]

  router_id = "${openstack_networking_router_v2.private.id}"

  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.airgap.prefixes, 0)}"
  next_hop = "${element(openstack_networking_port_v2.public_gateway_airgap.all_fixed_ips, 0)}"
}

// Airgap Router
resource "openstack_networking_router_route_v2" "airgap_to_private" {
  depends_on = [ "openstack_networking_router_interface_v2.private_port_public_gateway_airgap" ]

  router_id = "${openstack_networking_router_v2.airgap.id}"

  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.private.prefixes, 0)}"
  next_hop = "${element(openstack_networking_port_v2.public_gateway_private.all_fixed_ips, 0)}"
}

// Required to hit secondary public networks
resource "openstack_networking_router_route_v2" "airgap_to_public" {
  depends_on = [ "openstack_networking_router_interface_v2.private_port_public_gateway_airgap" ]

  router_id = "${openstack_networking_router_v2.airgap.id}"

  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.public.prefixes, 0)}"
  next_hop = "${openstack_networking_subnet_v2.public.gateway_ip}"
}
