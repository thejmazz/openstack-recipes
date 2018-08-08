// === PUBLIC NETWORK ===

resource "openstack_networking_network_v2" "public" {
  name = "${var.project_name}_public"
}

resource "openstack_networking_subnet_v2" "public" {
  network_id = "${openstack_networking_network_v2.public.id}"

  name = "${openstack_networking_network_v2.public.name}"

  cidr = "10.50.0.0/24"
  gateway_ip = "10.50.0.1"
  allocation_pools = {
    start = "10.50.0.2"
    end = "10.50.0.254"
  }

  ip_version = "4"
  enable_dhcp = true
}

resource "openstack_networking_router_v2" "public" {
  external_network_id = "${var.external_network_id}"

  name = "${openstack_networking_network_v2.public.name}"
}

resource "openstack_networking_router_interface_v2" "public" {
  router_id = "${openstack_networking_router_v2.public.id}"
  subnet_id = "${openstack_networking_subnet_v2.public.id}"
}

// === PRIVATE NETWORK ===

resource "openstack_networking_network_v2" "private" {
  name = "${var.project_name}_private"
}

resource "openstack_networking_subnet_v2" "private" {
  network_id = "${openstack_networking_network_v2.private.id}"

  name = "${openstack_networking_network_v2.private.name}"

  cidr = "10.51.0.0/24"
  gateway_ip = "10.51.0.1"
  allocation_pools = {
    start = "10.51.0.2"
    end = "10.51.0.254"
  }

  ip_version = "4"
  enable_dhcp = true
}

resource "openstack_networking_router_v2" "private" {
  name = "${openstack_networking_network_v2.private.name}"
}

resource "openstack_networking_router_interface_v2" "private" {
  router_id = "${openstack_networking_router_v2.private.id}"
  subnet_id = "${openstack_networking_subnet_v2.private.id}"
}

// === AIRGAP NETWORK ===

resource "openstack_networking_network_v2" "airgap" {
  name = "${var.project_name}_airgap"
}

resource "openstack_networking_subnet_v2" "airgap" {
  network_id = "${openstack_networking_network_v2.airgap.id}"

  name = "${openstack_networking_network_v2.airgap.name}"

  cidr = "10.52.0.0/24"
  gateway_ip = "10.52.0.1"
  allocation_pools = {
    start = "10.52.0.2"
    end = "10.52.0.254"
  }

  dns_nameservers = [ "10.50.0.2", "10.50.0.3" ]

  ip_version = "4"
  enable_dhcp = true
}

resource "openstack_networking_router_v2" "airgap" {
  name = "${openstack_networking_network_v2.airgap.name}"
}

resource "openstack_networking_router_interface_v2" "airgap" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  subnet_id = "${openstack_networking_subnet_v2.airgap.id}"
}

// === CONNECT PUBLIC NETWORK TO PRIVATE ROUTER ===

resource "openstack_networking_port_v2" "public_254" {
  network_id = "${openstack_networking_network_v2.public.id}"

  name = "public_254"

  fixed_ip = {
    subnet_id = "${openstack_networking_subnet_v2.public.id}"
    ip_address = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", 254)}"
  }

  admin_state_up = true
}

resource "openstack_networking_router_interface_v2" "private_interface_public_254" {
  router_id = "${openstack_networking_router_v2.private.id}"
  port_id = "${openstack_networking_port_v2.public_254.id}"
}

// === CONNECT PUBLIC NETWORK TO AIRGAP ROUTER ===

resource "openstack_networking_port_v2" "public_253" {
  network_id = "${openstack_networking_network_v2.public.id}"

  name = "public_253"

  fixed_ip = {
    subnet_id = "${openstack_networking_subnet_v2.public.id}"
    ip_address = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", 253)}"
  }

  admin_state_up = true
}

resource "openstack_networking_router_interface_v2" "airgap_interface_public_253" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  port_id = "${openstack_networking_port_v2.public_253.id}"
}

// === DIRECT PUBLIC TO PRIVATE ===

resource "openstack_networking_router_route_v2" "public_to_private" {
  depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_254" ]

  router_id = "${openstack_networking_router_v2.public.id}"

  destination_cidr = "${openstack_networking_subnet_v2.private.cidr}"
  next_hop = "${element(openstack_networking_port_v2.public_254.all_fixed_ips, 0)}"
}

// === DIRECT PUBLIC TO AIRGAP ===

resource "openstack_networking_router_route_v2" "public_to_airgap" {
  depends_on = [ "openstack_networking_router_interface_v2.airgap_interface_public_253" ]

  router_id = "${openstack_networking_router_v2.public.id}"

  destination_cidr = "${openstack_networking_subnet_v2.airgap.cidr}"
  next_hop = "${element(openstack_networking_port_v2.public_253.all_fixed_ips, 0)}"
}

// === DIRECT PRIVATE TO EXTERNAL GATEWAY ===

resource "openstack_networking_router_route_v2" "private_to_airgap" {
  depends_on = [
    "openstack_networking_router_interface_v2.public",
    "openstack_networking_router_interface_v2.private_interface_public_254"
  ]

  router_id = "${openstack_networking_router_v2.private.id}"

  destination_cidr = "0.0.0.0/0"
  next_hop = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", 1)}"
}

// === DIRECT AIRGAP TO PUBLIC'S DEFAULT GATEWAY ===

resource "openstack_networking_router_route_v2" "airgap_to_public" {
  depends_on = [
    "openstack_networking_router_interface_v2.public",
    "openstack_networking_router_interface_v2.airgap_interface_public_253"
  ]

  router_id = "${openstack_networking_router_v2.airgap.id}"

  destination_cidr = "10.0.0.0/8"
  next_hop = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", 1)}"
}
