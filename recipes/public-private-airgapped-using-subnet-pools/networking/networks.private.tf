data "openstack_networking_subnetpool_v2" "private" {
  name = "${var.project_name}_private"
}

resource "openstack_networking_network_v2" "private" {
  name = "${var.project_name}_private"
}

resource "openstack_networking_subnet_v2" "private" {
  network_id = "${openstack_networking_network_v2.private.id}"
  name = "${openstack_networking_network_v2.private.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.private.id}"

  ip_version = "4"
  enable_dhcp = true
}


resource "openstack_networking_network_v2" "private2" {
  name = "${var.project_name}_private2"
}

resource "openstack_networking_subnet_v2" "private2" {
  network_id = "${openstack_networking_network_v2.private2.id}"
  name = "${openstack_networking_network_v2.private2.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.private.id}"

  ip_version = "4"
  enable_dhcp = true
}
