resource "openstack_networking_network_v2" "etcd" {
  name = "${var.project_name}_etcd"
}

resource "openstack_networking_subnet_v2" "etcd" {
  network_id = "${openstack_networking_network_v2.etcd.id}"
  name = "${openstack_networking_network_v2.etcd.name}"

  subnetpool_id = "${openstack_networking_subnetpool_v2.private.id}"
}

resource "openstack_networking_router_interface_v2" "etcd" {
  router_id = "${openstack_networking_router_v2.private.id}"
  subnet_id = "${openstack_networking_subnet_v2.etcd.id}"
}
