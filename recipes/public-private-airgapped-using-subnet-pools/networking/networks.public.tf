resource "openstack_networking_network_v2" "public" {
  name = "${var.project_name}_public"
}

resource "openstack_networking_subnet_v2" "public" {
  network_id = "${openstack_networking_network_v2.public.id}"
  name = "${openstack_networking_network_v2.public.name}"

  subnetpool_id = "${openstack_networking_subnetpool_v2.public.id}"
}


resource "openstack_networking_network_v2" "public2" {
  name = "${var.project_name}_public2"
}

resource "openstack_networking_subnet_v2" "public2" {
  network_id = "${openstack_networking_network_v2.public2.id}"
  name = "${openstack_networking_network_v2.public2.name}"

  subnetpool_id = "${openstack_networking_subnetpool_v2.public.id}"
}
