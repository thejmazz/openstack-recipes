resource "openstack_compute_instance_v2" "bastion" {
  name = "${var.project_name}-bastion"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "tiny"

  network = {
    name = "${var.network_public}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "controller" {
  name = "${var.project_name}-controller"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "tiny"

  network = {
    name = "${var.network_public}"
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "etcds" {
  count = "${var.etcd_count}"

  name = "${var.project_name}-etcd-${count.index + 1}"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "m1.small"

  network = {
    name = "${var.network_private}"
  }

  metadata = {
    rke_node = ""
    rke_role_etcd = ""
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "controlplanes" {
  count = "${var.controlplane_count}"

  name = "${var.project_name}-controlplane-${count.index + 1}"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "m1.small"

  network = {
    name = "${var.network_private}"
  }

  metadata = {
    rke_node = ""
    rke_role_controlplane = ""
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "masters" {
  count = "${var.stacked_count}"

  name = "${var.project_name}-master-${count.index + 1}"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "m1.small"

  network = {
    name = "${var.network_private}"
  }

  metadata = {
    rke_node = ""
    rke_role_controlplane = ""
    rke_role_etcd = ""
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}

resource "openstack_compute_instance_v2" "workers" {
  count = "${var.worker_count}"

  name = "${var.project_name}-worker-${count.index + 1}"

  image_name = "ubuntu_1604_20180703_docker_17-06-2_1532301831"
  flavor_name = "m1.small"

  network = {
    name = "${var.network_private}"
  }

  metadata = {
    rke_node = ""
    rke_role_worker = ""
  }

  security_groups = [
    "debug_all"
  ]

  user_data = "${file("cloud-config.yml")}"

  key_pair = "${var.key_pair}"
}
