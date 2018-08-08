provider "openstack" {
  version = "~> 1.6"
}

module "networking" {
  source = "./networking"

  project_name = "${var.project_name}"
  external_network_id = "${var.external_network_id}"
}
