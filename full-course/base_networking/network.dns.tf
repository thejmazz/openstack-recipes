resource "openstack_networking_network_v2" "dns" {
  name = "${var.project_name}_dns"
}

resource "openstack_networking_subnet_v2" "dns" {
  network_id = "${openstack_networking_network_v2.dns.id}"
  name = "${openstack_networking_network_v2.dns.name}"

  subnetpool_id = "${openstack_networking_subnetpool_v2.private.id}"

  dns_nameservers = [
    "8.8.8.8",
    "8.8.4.4"
  ]
}
