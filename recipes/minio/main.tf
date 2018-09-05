provider "openstack" {
  version = "~> 1.8"
}

module "compute" {
  source = "./compute"

  project_name = "recipe-etcd"

  count = "1"
  key_pair = "${var.key_pair}"
  network = "private"
}
