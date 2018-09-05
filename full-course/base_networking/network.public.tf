resource "openstack_networking_network_v2" "public" {
  name = "${var.project_name}_public"
}

resource "openstack_networking_subnet_v2" "public" {
  network_id = "${openstack_networking_network_v2.public.id}"
  name = "${openstack_networking_network_v2.public.name}"

  subnetpool_id = "${openstack_networking_subnetpool_v2.public.id}"

  dns_nameservers = "${var.dns_nameservers}"
}
