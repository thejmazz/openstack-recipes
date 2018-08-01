resource "openstack_compute_instance_v2" "public" {
  name = "${var.project_name}_public_test"

  image_name = "ubuntu_1604_20180703_base"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.public.name}"
    fixed_ip_v4 = "10.111.0.10"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "private" {
  name = "${var.project_name}_private_test"

  image_name = "ubuntu_1604_20180703_base"
  flavor_name = "tiny"

  network = {
    name = "${openstack_networking_network_v2.private.name}"
    fixed_ip_v4 = "10.222.0.10"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}
