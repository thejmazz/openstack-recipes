data "openstack_images_image_v2" "ubuntu_docker" {
  most_recent = true

  properties {
    os_distro = "ubuntu"
    os_version = "16.04"
    docker_version = "17.06.2"
  }
}

resource "openstack_compute_instance_v2" "postgres" {
  /* name = "${var.project_name}.gitea.postgres" */
  name = "postgres.gitea.${var.project_name}"

  image_name = "${data.openstack_images_image_v2.ubuntu_docker.name}"
  flavor_name = "tiny"

  network = {
    name = "${var.network}"
  }

  security_groups = [
    "debug_all"
  ]

  metadata {
    role = "postgres"
    app = "gitea"
    mounts = "{ \"vdb\": \"/var/lib/postgresql\" }"
    postgres_backup = "gitea.2018-08-30T00:09:11Z.sql.gz"
    postgres_backup_bucket = "gitea-pg-dumps"
    postgres_db_name = "gitea"
    postgres_db_user = "gitea"
  }

  block_device {
    uuid = "${data.openstack_images_image_v2.ubuntu_docker.id}"
    source_type = "image"
    destination_type = "local"
    boot_index = 0
    delete_on_termination = false
  }

  block_device {
    source_type = "blank"
    destination_type = "volume"
    volume_size = 1
    boot_index = -1
    delete_on_termination = true
  }

  key_pair = "${var.key_pair}"
}

data "openstack_images_image_v2" "gitea_var-lib-gitea" {
  most_recent = true

  properties {
    project = "${var.project_name}"
    app = "gitea"
    mount_path = "/var/lib/gitea"
  }
}

resource "openstack_blockstorage_volume_v3" "gitea_var-lib-gitea" {
  name = "${var.project_name}_gitea_var-lib-gitea_${timestamp()}"
  description = "/var/lib/gitea"
  size = 2
  image_id = "${data.openstack_images_image_v2.gitea_var-lib-gitea.id}"

  lifecycle {
    ignore_changes = [ "name" ]
  }
}

data "openstack_images_image_v2" "gitea_repositories" {
  most_recent = true

  properties {
    project = "${var.project_name}"
    app = "gitea"
    mount_path = "/home/git/gitea-repositories"
  }
}

resource "openstack_blockstorage_volume_v3" "gitea_repositories" {
  name = "${var.project_name}_gitea_repositories_${timestamp()}"
  description = "/home/git/gitea-repositories"
  size = 2
  image_id = "${data.openstack_images_image_v2.gitea_repositories.id}"

  lifecycle {
    ignore_changes = [ "name" ]
  }
}

resource "openstack_compute_instance_v2" "gitea" {
  name = "gitea.${var.project_name}"

  image_name = "${data.openstack_images_image_v2.ubuntu_docker.name}"
  flavor_name = "tiny"

  network = {
    name = "${var.network}"
  }

  security_groups = [
    "debug_all"
  ]

  metadata {
    role = "gitea"
    app = "gitea"
    mounts = "{ \"vdb\":\"/var/lib/gitea\", \"vdc\":\"/home/git/gitea-repositories\" }"
  }

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_volume_attach_v2" "gitea_vdb" {
  instance_id = "${openstack_compute_instance_v2.gitea.id}"
  volume_id   = "${openstack_blockstorage_volume_v3.gitea_var-lib-gitea.id}"
}

resource "openstack_compute_volume_attach_v2" "gitea_vdc" {
  instance_id = "${openstack_compute_instance_v2.gitea.id}"
  volume_id   = "${openstack_blockstorage_volume_v3.gitea_repositories.id}"

  depends_on = [ "openstack_compute_volume_attach_v2.gitea_vdb" ]
}
