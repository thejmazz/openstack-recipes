provider "openstack" {
  version = "~> 1.8"
}

data "openstack_images_image_v2" "ubuntu_docker" {
  most_recent = true

  properties {
    os_distro = "ubuntu"
    os_version = "16.04"
    docker_version = "17.06.2"
  }
}


resource "openstack_compute_instance_v2" "gitea" {
  name = "${var.project_name}-git"

  image_name = "${data.openstack_images_image_v2.ubuntu_docker.name}"
  flavor_name = "tiny"

  network = {
    name = "${var.network}"
  }

  security_groups = [
    "debug_all"
  ]

  key_pair = "${var.key_pair}"
}

resource "openstack_blockstorage_volume_v3" "gitea_var_lib_gitea" {
  name = "gitea_var_lib_gitea_2"
  size = 2
  image_id = "cf62bf41-026e-4053-bf2b-5f0418096809"
  description = "/var/lib/gitea"
}

resource "openstack_compute_volume_attach_v2" "vdb" {
  instance_id = "${openstack_compute_instance_v2.gitea.id}"
  volume_id   = "${openstack_blockstorage_volume_v3.gitea_var_lib_gitea.id}"
}


resource "openstack_blockstorage_volume_v3" "gitea_repositories" {
  name = "gitea_repositories_2"
  size = 2
  image_id = "f6f7acad-a4ff-472c-af6c-7f0651c48de1"
  description = "/home/git/gitea-repositories"
}

resource "openstack_compute_volume_attach_v2" "vdc" {
  depends_on = [ "openstack_compute_volume_attach_v2.vdb" ]

  instance_id = "${openstack_compute_instance_v2.gitea.id}"
  volume_id   = "${openstack_blockstorage_volume_v3.gitea_repositories.id}"
}
