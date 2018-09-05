data "openstack_images_image_v2" "ubuntu_docker" {
  most_recent = true

  properties {
    os_distro = "ubuntu"
    os_version = "16.04"
    docker_version = "17.06.2"
  }
}

data "openstack_networking_subnet_v2" "dns" {
  name = "${var.subnet}"
}

resource "openstack_compute_instance_v2" "coredns" {
  count = "${var.count}"
  name = "${var.project_name}-coredns-${count.index + 1}"

  image_name = "${data.openstack_images_image_v2.ubuntu_docker.name}"
  flavor_name = "tiny"

  network = {
    name = "${var.network}"
    fixed_ip_v4 = "${cidrhost(data.openstack_networking_subnet_v2.dns.cidr, 10 + count.index)}"
  }

  security_groups = [
    "debug_all"
  ]

  metadata {
    network = "dns"
    role_coredns = ""
    role_etcd = ""
  }

  key_pair = "${var.key_pair}"
}
