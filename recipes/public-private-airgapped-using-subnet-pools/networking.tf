// === CONVENTIONS ===

// one-network-one-subnet

data "openstack_networking_subnetpool_v2" "public" {
  name = "public"
}

data "openstack_networking_subnetpool_v2" "private" {
  name = "private"
}

data "openstack_networking_subnetpool_v2" "airgap" {
  name = "airgap"
}

// === NETWORK: <project-name>_public ===
// 10.100.0.0/24

resource "openstack_networking_network_v2" "public" {
  name = "${var.project_name}_public"
}

resource "openstack_networking_subnet_v2" "public" {
  network_id = "${openstack_networking_network_v2.public.id}"

  name = "${openstack_networking_network_v2.public.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.public.id}"

  ip_version = "4"
  enable_dhcp = true
}

// === NETWORK: <project-name>_public2 ===
// 10.100.0.0/24

resource "openstack_networking_network_v2" "public2" {
  name = "${var.project_name}_public2"
}

resource "openstack_networking_subnet_v2" "public2" {
  network_id = "${openstack_networking_network_v2.public2.id}"

  name = "${openstack_networking_network_v2.public2.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.public.id}"

  ip_version = "4"
  enable_dhcp = true
}

// === ROUTER: public ===

// This router has an external gateway so it can reach the public internet

resource "openstack_networking_router_v2" "public" {
  external_network_id = "${var.external_network_id}"

  name = "${var.project_name}_public_router"
}

// Add the default gateway port (typically .1, so in this case 10.100.0.1) to the public router
// At this point, instances in public network can reach the public internet.
// This means malicious users could get access to the internet from the air-gapped network by
// communicating through a proxy instance on a network that has egress access.

// Implicitly, this associates the port tied to 10.100.0.1 with the router
// (associating from subnet ID is a convenience)
resource "openstack_networking_router_interface_v2" "public" {
  router_id = "${openstack_networking_router_v2.public.id}"
  subnet_id = "${openstack_networking_subnet_v2.public.id}"
}

resource "openstack_networking_router_interface_v2" "public2" {
  router_id = "${openstack_networking_router_v2.public.id}"
  subnet_id = "${openstack_networking_subnet_v2.public2.id}"
}

// === NETWORK: <project-name>_private ===

resource "openstack_networking_network_v2" "private" {
  name = "${var.project_name}_private"
}

resource "openstack_networking_subnet_v2" "private" {
  network_id = "${openstack_networking_network_v2.private.id}"

  name = "${openstack_networking_network_v2.private.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.private.id}"

  ip_version = "4"
  enable_dhcp = true

  /* dns_nameservers = [ */
  /*   "10.100.0.2", */
  /*   "10.100.0.3" */
  /* ] */
}

// === NETWORK: <project-name>_private2 ===

resource "openstack_networking_network_v2" "private2" {
  name = "${var.project_name}_private2"
}

resource "openstack_networking_subnet_v2" "private2" {
  network_id = "${openstack_networking_network_v2.private2.id}"

  name = "${openstack_networking_network_v2.private2.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.private.id}"

  ip_version = "4"
  enable_dhcp = true

  /* dns_nameservers = [ */
  /*   "10.100.0.2", */
  /*   "10.100.0.3" */
  /* ] */
}

// === ROUTER: private ===

// No external gateway. Instances whose gateway (in this case, 10.102.0.1) is
// attached to this router will not have access to the public internet.
resource "openstack_networking_router_v2" "private" {
  name = "${var.project_name}_private"
}

// Associate 10.102.0.1 with the private router
resource "openstack_networking_router_interface_v2" "private" {
  router_id = "${openstack_networking_router_v2.private.id}"
  subnet_id = "${openstack_networking_subnet_v2.private.id}"
}


// Associate private2 with router
resource "openstack_networking_router_interface_v2" "private2" {
  router_id = "${openstack_networking_router_v2.private.id}"
  subnet_id = "${openstack_networking_subnet_v2.private2.id}"
}


// === NETWORK: <project-name>_airgap ===

resource "openstack_networking_network_v2" "airgap" {
  name = "${var.project_name}_airgap"
}

resource "openstack_networking_subnet_v2" "airgap" {
  network_id = "${openstack_networking_network_v2.airgap.id}"

  name = "${openstack_networking_network_v2.airgap.name}"

  /* cidr = "10.101.0.0/24" */
  subnetpool_id = "${data.openstack_networking_subnetpool_v2.airgap.id}"
  /* gateway_ip = "10.101.0.1" */
  /* allocation_pools = { */
  /*   start = "10.101.0.2" */
  /*   end = "10.101.0.254" */
  /* } */

  ip_version = "4"
  enable_dhcp = true

  /* dns_nameservers = [ */
  /*   "10.100.0.2", */
  /*   "10.100.0.3" */
  /* ] */
}

// === NETWORK: <project-name>_airgap ===

resource "openstack_networking_network_v2" "airgap2" {
  name = "${var.project_name}_airgap2"
}

resource "openstack_networking_subnet_v2" "airgap2" {
  network_id = "${openstack_networking_network_v2.airgap2.id}"

  name = "${openstack_networking_network_v2.airgap2.name}"

  /* cidr = "10.101.0.0/24" */
  subnetpool_id = "${data.openstack_networking_subnetpool_v2.airgap.id}"
  /* gateway_ip = "10.101.0.1" */
  /* allocation_pools = { */
  /*   start = "10.101.0.2" */
  /*   end = "10.101.0.254" */
  /* } */

  ip_version = "4"
  enable_dhcp = true

  /* dns_nameservers = [ */
  /*   "10.100.0.2", */
  /*   "10.100.0.3" */
  /* ] */
}

resource "openstack_networking_router_v2" "airgap" {
  name = "${var.project_name}_airgap"
}

resource "openstack_networking_router_interface_v2" "airgap" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  subnet_id = "${openstack_networking_subnet_v2.airgap.id}"
}

resource "openstack_networking_router_interface_v2" "airgap2" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  subnet_id = "${openstack_networking_subnet_v2.airgap2.id}"
}

// Extra ports on public network as interfaces onto private/airgap routers
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

resource "openstack_networking_port_v2" "public_253" {
  network_id = "${openstack_networking_network_v2.public.id}"

  name = "public_253"

  fixed_ip = {
    subnet_id = "${openstack_networking_subnet_v2.public.id}"
    ip_address = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", 253)}"
  }

  admin_state_up = true
}
resource "openstack_networking_router_interface_v2" "private_interface_public_253" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  port_id = "${openstack_networking_port_v2.public_253.id}"
}

// === ROUTES on 'public' ROUTER ===

resource "openstack_networking_router_route_v2" "public_to_private" {
  depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_254" ]

  router_id = "${openstack_networking_router_v2.public.id}"

  /* destination_cidr = "10.102.0.0/24" */
  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.private.prefixes, 0)}"
  next_hop = "${element(openstack_networking_port_v2.public_254.all_fixed_ips, 0)}"
  /* next_hop = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", 254)}" */
}

resource "openstack_networking_router_route_v2" "public_to_airgap" {
  depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_253" ]

  router_id = "${openstack_networking_router_v2.public.id}"

  /* destination_cidr = "10.101.0.0/24" */
  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.airgap.prefixes, 0)}"
  next_hop = "${element(openstack_networking_port_v2.public_253.all_fixed_ips, 0)}"
}

// === ROUTES on 'private' ROUTER ===


resource "openstack_networking_router_route_v2" "private_to_airgap" {
  depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_254" ]

  router_id = "${openstack_networking_router_v2.private.id}"

  destination_cidr = "0.0.0.0/0"
  /* next_hop = "10.100.0.1" */
  next_hop = "${openstack_networking_subnet_v2.public.gateway_ip}"
}

resource "openstack_networking_router_route_v2" "private_to_airgap2" {
  depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_254" ]

  router_id = "${openstack_networking_router_v2.private.id}"

  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.airgap.prefixes, 0)}"
  next_hop = "${element(openstack_networking_port_v2.public_253.all_fixed_ips, 0)}"
}

// === ROUTES on 'airgap' ROUTER ===

resource "openstack_networking_router_route_v2" "airgap_to_private" {
  depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_253" ]

  router_id = "${openstack_networking_router_v2.airgap.id}"

  /* destination_cidr = "10.102.0.0/24" */
  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.private.prefixes, 0)}"
  /* next_hop = "10.100.0.1" */
  next_hop = "${element(openstack_networking_port_v2.public_254.all_fixed_ips, 0)}"
}

// Required to hit secondary public networks
resource "openstack_networking_router_route_v2" "airgap_to_public" {
  depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_253" ]

  router_id = "${openstack_networking_router_v2.airgap.id}"

  /* destination_cidr = "10.102.0.0/24" */
  destination_cidr = "${element(data.openstack_networking_subnetpool_v2.public.prefixes, 0)}"
  /* next_hop = "10.100.0.1" */
  next_hop = "${openstack_networking_subnet_v2.public.gateway_ip}"
}
