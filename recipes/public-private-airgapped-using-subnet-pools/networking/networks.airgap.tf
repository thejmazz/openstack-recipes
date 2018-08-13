data "openstack_networking_subnetpool_v2" "airgap" {
  name = "${var.project_name}_airgap"
}

resource "openstack_networking_network_v2" "airgap" {
  name = "${var.project_name}_airgap"
}

resource "openstack_networking_subnet_v2" "airgap" {
  network_id = "${openstack_networking_network_v2.airgap.id}"
  name = "${openstack_networking_network_v2.airgap.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.airgap.id}"
}


resource "openstack_networking_network_v2" "airgap2" {
  name = "${var.project_name}_airgap2"
}

resource "openstack_networking_subnet_v2" "airgap2" {
  network_id = "${openstack_networking_network_v2.airgap2.id}"
  name = "${openstack_networking_network_v2.airgap2.name}"

  subnetpool_id = "${data.openstack_networking_subnetpool_v2.airgap.id}"
}
