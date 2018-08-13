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
  external_network_name = "${var.external_network_name}"
  key_pair = "${var.key_pair}"
  etcd_count = "3"
}

output bastion_fip {
  value = "${module.compute.bastion_fip}"
}
