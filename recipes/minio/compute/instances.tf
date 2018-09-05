data "openstack_images_image_v2" "ubuntu_docker" {
  most_recent = true

  properties {
    os_distro = "ubuntu"
    os_version = "16.04"
    docker_version = "17.06.2"
  }
}

resource "openstack_blockstorage_volume_v3" "minio_data" {
  name = "minio_data"
  description = "/data"
  size = 10
  image_id = "003009fa-65b9-4c91-b31f-2d7505bdb0fe"
  enable_online_resize = true
}

resource "openstack_compute_instance_v2" "minio" {
  count = "${var.count}"
  name = "${var.project_name}-minio-${count.index + 1}"

  image_name = "${data.openstack_images_image_v2.ubuntu_docker.name}"
  flavor_name = "tiny"

  network = {
    name = "${var.project_name}_${var.network}"
  }

  security_groups = [
    "debug_all"
  ]

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_volume_attach_v2" "minio_data" {
  instance_id = "${openstack_compute_instance_v2.minio.id}"
  volume_id   = "${openstack_blockstorage_volume_v3.minio_data.id}"
}
