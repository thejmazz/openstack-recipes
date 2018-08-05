resource "openstack_compute_instance_v2" "controller" {
  name = "${var.project_name}_controller"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.public.name}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "master" {
  name = "${var.project_name}_master"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "m1.small"

  network = {
    name = "${openstack_networking_network_v2.public.name}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "workers" {
  count = "2"

  name = "${var.project_name}_worker-${count.index + 1}"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "m1.small"

  network = {
    name = "${openstack_networking_network_v2.public.name}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}
