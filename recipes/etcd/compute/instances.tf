resource "openstack_compute_instance_v2" "bastion" {
  name = "${var.project_name}-bastion"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "tiny"

  network = {
    name = "${var.project_name}_public"
  }

  security_groups = [
    "debug_all"
  ]

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "controller" {
  name = "${var.project_name}-controller"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "tiny"

  network = {
    name = "${var.project_name}_private"
  }

  security_groups = [
    "debug_all"
  ]

  key_pair = "${var.key_pair}"
}

data "openstack_networking_subnet_v2" "etcd" {
  name = "${var.project_name}_etcd"
}

resource "openstack_compute_instance_v2" "etcd" {
  count = "${var.etcd_count}"
  name = "${var.project_name}-etcd-${count.index + 1}"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "m1.small"

  network = {
    name = "${var.project_name}_etcd"
    fixed_ip_v4 = "${cidrhost(data.openstack_networking_subnet_v2.etcd.cidr, 10 + count.index)}"
  }

  security_groups = [
    "debug_all"
  ]

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "cfssl" {
  name = "${var.project_name}-cfssl"

  image_name = "pkitest_ubuntu_1604_cfssl_1-3-2"
  flavor_name = "tiny"

  network = {
    name = "${var.project_name}_rootca"
  }

  security_groups = [
    "debug_all"
  ]

  key_pair = "${var.key_pair}"
}
