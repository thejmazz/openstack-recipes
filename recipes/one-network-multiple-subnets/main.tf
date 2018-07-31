provider "openstack" {
  version = "~> 1.6"
}

variable network_name {}
variable image_name {
  default = "Ubuntu 16.04 LTS"
}
variable flavor_name {
  default = "tiny"
}

// === NETWORK ===

resource "openstack_networking_network_v2" "net" {
  name = "${var.network_name}"
}

// === SUBNETS ===

resource "openstack_networking_subnet_v2" "subnet-one" {
  network_id = "${openstack_networking_network_v2.net.id}"

  name = "${var.network_name}-10"

  cidr = "10.10.0.0/24"
  gateway_ip = "10.10.0.1"
  allocation_pools = {
    start = "10.10.0.2"
    end = "10.10.0.254"
  }

  ip_version = "4"
  enable_dhcp = true
}

resource "openstack_networking_subnet_v2" "subnet-two" {
  network_id = "${openstack_networking_network_v2.net.id}"

  name = "${var.network_name}-10"

  cidr = "10.20.0.0/24"
  gateway_ip = "10.20.0.1"
  allocation_pools = {
    start = "10.20.0.2"
    end = "10.20.0.254"
  }

  ip_version = "4"
  enable_dhcp = true
}

// === INSTANCES ===

resource "openstack_compute_instance_v2" "subnet-one-test" {
  name = "test-10"

  image_name = "${var.image_name}"
  flavor_name = "${var.flavor_name}"

  user_data = "${file(cloud-config.yml)}"

  network = {
    name = "${openstack_networking_network_v2.net.name}"
    fixed_ip_v4 = "10.10.0.5"
  }

  security_groups = [
    "default"
  ]
}

resource "openstack_compute_instance_v2" "subnet-two-test" {
  name = "test-20"

  image_name = "${var.image_name}"
  flavor_name = "${var.flavor_name}"

  user_data = "${file(cloud-config.yml)}"

  network = {
    name = "${openstack_networking_network_v2.net.name}"
    fixed_ip_v4 = "10.20.0.5"
  }

  security_groups = [
    "default"
  ]
}
