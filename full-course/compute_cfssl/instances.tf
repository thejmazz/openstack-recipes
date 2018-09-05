resource "openstack_compute_instance_v2" "cfssl" {
  name = "${var.project_name}-cfssl"

  image_name = "pkitest_ubuntu_1604_cfssl_1-3-2"
  flavor_name = "tiny"

  network = {
    name = "${var.network}"
  }

  security_groups = [
    "debug_all"
  ]

  metadata {
    role_cfssl = ""
  }

  key_pair = "${var.key_pair}"
}
