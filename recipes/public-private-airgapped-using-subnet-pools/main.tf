provider "openstack" {
  version = "~> 1.8"
}

module "networking" {
  source = "./networking"

  project_name = "${var.project_name}"
  external_network_id = "${var.external_network_id}"
}

module "compute" {
  source = "./compute"

  project_name = "${var.project_name}"
  key_pair = "${var.key_pair}"
}

module "floating_ips" {
  source = "./floating_ips"

  external_network_name = "${var.external_network_name}"
  instance_public_id = "${module.compute.instance_public_id}"
}
