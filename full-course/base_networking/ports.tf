resource "openstack_networking_port_v2" "public_gateway_private" {
  network_id = "${openstack_networking_network_v2.public.id}"

  name = "public_gateway_private"

  fixed_ip = {
    subnet_id = "${openstack_networking_subnet_v2.public.id}"
    ip_address = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", -2)}" // 254
  }

  admin_state_up = true
}

resource "openstack_networking_port_v2" "public_gateway_airgap" {
  network_id = "${openstack_networking_network_v2.public.id}"

  name = "public_gateway_airgap"

  fixed_ip = {
    subnet_id = "${openstack_networking_subnet_v2.public.id}"
    ip_address = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", -3)}" // 253
  }

  admin_state_up = true
}
