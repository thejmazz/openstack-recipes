data "openstack_images_image_v2" "ubuntu_docker" {
  most_recent = true

  properties {
    os_distro = "ubuntu"
    os_version = "16.04"
    docker_version = "17.06.2"
  }
}

resource "openstack_compute_instance_v2" "ingress" {
  name = "${var.project_name}-ingress"

  image_name = "${data.openstack_images_image_v2.ubuntu_docker.name}"
  flavor_name = "tiny"

  network = {
    name = "${var.network}"
  }

  security_groups = [
    /* "ssh_from_kidnet", */
    /* "public-http-and-https", */
    /* "egress" */
    "debug_all"
  ]

  key_pair = "${var.key_pair}"
}
