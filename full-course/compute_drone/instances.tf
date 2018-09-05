data "openstack_images_image_v2" "ubuntu_docker" {
  most_recent = true

  properties {
    os_distro = "ubuntu"
    os_version = "16.04"
    docker_version = "17.06.2"
  }
}

resource "openstack_compute_instance_v2" "drone-server" {
  /* name = "${var.project_name}.gitea.postgres" */
  name = "server.drone.${var.project_name}"

  image_name = "${data.openstack_images_image_v2.ubuntu_docker.name}"
  flavor_name = "tiny"

  network = {
    name = "${var.network}"
  }

  security_groups = [
    "debug_all"
  ]

  metadata {
    role = "drone-server"
    app = "drone"
    mounts = "{}"
    /* mounts = "{ \"vdb\": \"/var/lib/docker\" }" */
  }

  /* block_device { */
  /*   uuid = "${data.openstack_images_image_v2.ubuntu_docker.id}" */
  /*   source_type = "image" */
  /*   destination_type = "local" */
  /*   boot_index = 0 */
  /*   delete_on_termination = false */
  /* } */

  /* block_device { */
  /*   source_type = "blank" */
  /*   destination_type = "volume" */
  /*   volume_size = 1 */
  /*   boot_index = -1 */
  /*   delete_on_termination = true */
  /* } */

  key_pair = "${var.key_pair}"
}
