provider "openstack" {
  version = "~> 1.8"
}

module "networking" {
  source = "./networking"

  project_name = "recipe-etcd"

  subnetpool = "private"
  router_id = "5787651c-fef3-4f08-a97c-1bb38f9fd13e"
}

module "compute" {
  source = "./compute"

  project_name = "recipe-etcd"

  count = "1"
  key_pair = "candig_dev_key"
  network = "${module.networking.network}"
  subnet = "${module.networking.subnet}"
}
