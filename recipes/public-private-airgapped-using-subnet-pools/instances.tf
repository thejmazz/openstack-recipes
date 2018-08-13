resource "openstack_compute_instance_v2" "public" {
  name = "${var.project_name}-public-test"

  image_name = "ubuntu_1604_20180703_base"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.public.name}"
    fixed_ip_v4 = "${cidrhost("${openstack_networking_subnet_v2.public.cidr}", 10)}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "public2" {
  name = "${var.project_name}-public2-test"

  image_name = "ubuntu_1604_20180703_base"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.public2.name}"
    fixed_ip_v4 = "${cidrhost("${openstack_networking_subnet_v2.public2.cidr}", 10)}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "private" {
  name = "${var.project_name}-private-test"

  image_name = "ubuntu_1604_20180703_base"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.private.name}"
    fixed_ip_v4 = "${cidrhost("${openstack_networking_subnet_v2.private.cidr}", 10)}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "private2" {
  name = "${var.project_name}-private2-test"

  image_name = "ubuntu_1604_20180703_base"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.private2.name}"
    fixed_ip_v4 = "${cidrhost("${openstack_networking_subnet_v2.private2.cidr}", 10)}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "airgap" {
  name = "${var.project_name}-airgap-test"

  image_name = "ubuntu_1604_20180703_base"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.airgap.name}"
    fixed_ip_v4 = "${cidrhost("${openstack_networking_subnet_v2.airgap.cidr}", 10)}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "airgap2" {
  name = "${var.project_name}-airgap2-test"

  image_name = "ubuntu_1604_20180703_base"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.airgap2.name}"
    fixed_ip_v4 = "${cidrhost("${openstack_networking_subnet_v2.airgap2.cidr}", 10)}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}
