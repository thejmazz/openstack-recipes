provider "openstack" {
  version = "~> 1.6"
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

  external_network_name = "${var.external_network_name}"

  network_public = "${module.networking.network_public}"
  network_private = "${module.networking.network_private}"
}

output "bastion_ip" {
  value = "${module.compute.bastion_ip}"
}

output "controller_ip" {
  value = "${module.compute.controller_ip}"
}
