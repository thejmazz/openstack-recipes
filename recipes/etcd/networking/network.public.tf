resource "openstack_networking_network_v2" "public" {
  name = "${var.project_name}_public"
}

resource "openstack_networking_subnet_v2" "public" {
  network_id = "${openstack_networking_network_v2.public.id}"
  name = "${openstack_networking_network_v2.public.name}"

  subnetpool_id = "${openstack_networking_subnetpool_v2.public.id}"
}

resource "openstack_networking_router_interface_v2" "public" {
  router_id = "${openstack_networking_router_v2.public.id}"
  subnet_id = "${openstack_networking_subnet_v2.public.id}"
}
