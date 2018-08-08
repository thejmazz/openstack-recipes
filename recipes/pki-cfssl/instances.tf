resource "openstack_compute_instance_v2" "web" {
  name = "${var.project_name}_web"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "tiny"

  network = {
    name = "${module.networking.public_name}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "rootca" {
  name = "${var.project_name}_rootca"

  image_name = "${var.project_name}_ubuntu_1604_cfssl_1-3-2"
  flavor_name = "tiny"

  network = {
    name = "${module.networking.airgap_name}"
  }

  security_groups = [
    "debug_all"
  ]

  // Purposefully leave this out so we cannot log in via console
  // user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}
