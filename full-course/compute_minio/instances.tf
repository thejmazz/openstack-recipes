data "openstack_images_image_v2" "ubuntu_docker" {
  most_recent = true

  properties {
    os_distro = "ubuntu"
    os_version = "16.04"
    docker_version = "17.06.2"
  }
}

data "openstack_images_image_v2" "minio_data" {
  most_recent = true

  properties {
    project = "${var.project_name}"
    app = "minio"
    mount_path = "/data"
  }
}

resource "openstack_blockstorage_volume_v3" "minio_data" {
  name = "${var.project_name}_minio"
  description = "/data"
  size = 2
  image_id = "${data.openstack_images_image_v2.minio_data.id}"
  enable_online_resize = true
}

resource "openstack_compute_instance_v2" "minio" {
  count = "${var.count}"
  name = "${var.project_name}-minio-${count.index + 1}"
  /* name = "${var.project_name}-minio-${format("%02d", count.index + 1)}" */

  image_name = "${data.openstack_images_image_v2.ubuntu_docker.name}"
  flavor_name = "tiny"

  network = {
    name = "${var.network}"
  }

  security_groups = [
    "debug_all"
  ]

  metadata {
    role = "minio"
    app = "minio"
    mounts = "{ \"vdb\":\"/var/lib/minio\" }"
  }

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_volume_attach_v2" "minio_vdb" {
  instance_id = "${openstack_compute_instance_v2.minio.id}"
  volume_id   = "${openstack_blockstorage_volume_v3.minio_data.id}"
}
