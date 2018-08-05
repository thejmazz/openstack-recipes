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

  name = "${var.project_name}_public_router"
}

resource "openstack_networking_router_interface_v2" "public" {
  router_id = "${openstack_networking_router_v2.public.id}"
  subnet_id = "${openstack_networking_subnet_v2.public.id}"
}
