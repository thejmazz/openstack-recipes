resource "openstack_networking_network_v2" "rootca" {
  name = "${var.project_name}_rootca"
}

resource "openstack_networking_subnet_v2" "rootca" {
  network_id = "${openstack_networking_network_v2.rootca.id}"
  name = "${openstack_networking_network_v2.rootca.name}"

  subnetpool_id = "${openstack_networking_subnetpool_v2.airgap.id}"

  /* dns_nameservers = [ "${openstack_networking_subnet_v2.private.dns_nameservers}" ] */
}

resource "openstack_networking_router_interface_v2" "rootca" {
  router_id = "${openstack_networking_router_v2.airgap.id}"
  subnet_id = "${openstack_networking_subnet_v2.rootca.id}"
}
