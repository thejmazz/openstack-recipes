// === CONVENTIONS ===

// one-network-one-subnet
// In this recipe, each network has a single router as well

// === NETWORK: <project-name>_public ===
// 10.100.0.0/24

resource "openstack_networking_network_v2" "public" {
  name = "${var.project_name}_public"
}

resource "openstack_networking_subnet_v2" "public" {
  network_id = "${openstack_networking_network_v2.public.id}"

  // one-network-one-subnet so just reuse the name
  name = "${openstack_networking_network_v2.public.name}"

  cidr = "10.100.0.0/24"
  gateway_ip = "10.100.0.1"
  allocation_pools = {
    start = "10.100.0.2"
    end = "10.100.0.254"
  }

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

// === NETWORK: <project-name>_private ===

resource "openstack_networking_network_v2" "private" {
  name = "${var.project_name}_private"
}

resource "openstack_networking_subnet_v2" "private" {
  network_id = "${openstack_networking_network_v2.private.id}"

  name = "${openstack_networking_network_v2.private.name}"

  cidr = "10.102.0.0/24"
  gateway_ip = "10.102.0.1"
  allocation_pools = {
    start = "10.102.0.2"
    end = "10.102.0.254"
  }

  ip_version = "4"
  enable_dhcp = true

  // OpenStack tends to apply .2 and .3 to be DHCP/DNS servers (but these can change over time?)
  // So hardcoding these (unless you are running your own DNS on fixed IPs) is a little sketchy
  // We point the private networks DNS to the the public network - the private
  // network will be able to resolve IPs from names, but is unable to actually
  // reach them. The private network will be able to actually reach these IPs
  // due to the static routes we will add to the router.
  // If the instance is created fast enough, it will take .3. (So I have set fixed ips on the instances to .10)
  dns_nameservers = [
    "10.100.0.2",
    "10.100.0.3"
  ]
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

// === NETWORK: <project-name>_airgap ===

resource "openstack_networking_network_v2" "airgap" {
  name = "${var.project_name}_airgap"
}

resource "openstack_networking_subnet_v2" "airgap" {
  network_id = "${openstack_networking_network_v2.airgap.id}"

  name = "${openstack_networking_network_v2.airgap.name}"

  cidr = "10.101.0.0/24"
  gateway_ip = "10.101.0.1"
  allocation_pools = {
    start = "10.101.0.2"
    end = "10.101.0.254"
  }

  ip_version = "4"
  enable_dhcp = true

  // OpenStack tends to apply .2 and .3 to be DHCP/DNS servers (but these can change over time?)
  // So hardcoding these (unless you are running your own DNS on fixed IPs) is a little sketchy
  // We point the private networks DNS to the the public network - the private
  // network will be able to resolve IPs from names, but is unable to actually
  // reach them. The private network will be able to actually reach these IPs
  // due to the static routes we will add to the router.
  // If the instance is created fast enough, it will take .3. (So I have set fixed ips on the instances to .10)
  dns_nameservers = [
    "10.100.0.2",
    "10.100.0.3"
  ]
}

resource "openstack_networking_router_v2" "airgap" {
  name = "${var.project_name}_airgap"
}

resource "openstack_networking_router_interface_v2" "airgap" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  subnet_id = "${openstack_networking_subnet_v2.airgap.id}"
}


// Extra ports on public network as interfaces onto private/airgap routers
resource "openstack_networking_port_v2" "public_254" {
  network_id = "${openstack_networking_network_v2.public.id}"

  name = "public_254"

  fixed_ip = {
    subnet_id = "${openstack_networking_subnet_v2.public.id}"
    ip_address = "10.100.0.254"
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
    ip_address = "10.100.0.253"
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

  destination_cidr = "10.102.0.0/24"
  next_hop = "10.100.0.254"
}

resource "openstack_networking_router_route_v2" "public_to_airgap" {
  depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_253" ]

  router_id = "${openstack_networking_router_v2.public.id}"

  destination_cidr = "10.101.0.0/24"
  next_hop = "10.100.0.253"
}

// === ROUTES on 'private' ROUTER ===


resource "openstack_networking_router_route_v2" "private_to_airgap" {
  /* depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_253" ] */

  router_id = "${openstack_networking_router_v2.private.id}"

  destination_cidr = "0.0.0.0/0"
  next_hop = "10.100.0.1"
}

// === ROUTES on 'airgap' ROUTER ===

resource "openstack_networking_router_route_v2" "airgap_to_private" {
  /* depends_on = [ "openstack_networking_router_interface_v2.private_interface_public_253" ] */

  router_id = "${openstack_networking_router_v2.airgap.id}"

  destination_cidr = "10.102.0.0/24"
  next_hop = "10.100.0.1"
}
