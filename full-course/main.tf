provider "openstack" {
  version = "~> 1.8"
}

module "base_networking" {
  source = "./base_networking"

  project_name = "${var.project_name}"
  external_network_id = "${var.external_network_id}"
  dns_nameservers = "${var.dns_nameservers}"
}

module "compute_ingress" {
  source = "./compute_ingress"

  project_name = "${var.project_name}"
  network = "${var.project_name}_public"
  key_pair = "${var.key_pair}"
  external_network_name = "${var.external_network_name}"
}

module "compute_dns" {
  source = "./compute_dns"

  count = "1"

  project_name = "${var.project_name}"
  network = "${var.project_name}_dns"
  subnet = "${var.project_name}_dns"
  key_pair = "${var.key_pair}"
}

module "compute_cfssl" {
  source = "./compute_cfssl"

  project_name = "${var.project_name}"
  network = "${var.project_name}_private"
  key_pair = "${var.key_pair}"
}

module "compute_etcd" {
  source = "./compute_etcd"

  count = "1"

  project_name = "${var.project_name}"
  network = "${var.project_name}_private"
  subnet = "${var.project_name}_private"
  key_pair = "${var.key_pair}"
}

module "compute_vault" {
  source = "./compute_vault"

  count = "1"

  project_name = "${var.project_name}"
  network = "${var.project_name}_private"
  key_pair = "${var.key_pair}"
}

module "compute_minio" {
  source = "./compute_minio"

  count = "1"

  project_name = "${var.project_name}"
  network = "${var.project_name}_private"
  key_pair = "${var.key_pair}"
}

module "compute_gitea" {
  source = "./compute_gitea"

  project_name = "${var.project_name}"
  network = "${var.project_name}_private"
  key_pair = "${var.key_pair}"
}

module "compute_drone" {
  source = "./compute_drone"

  project_name = "${var.project_name}"
  network = "${var.project_name}_private"
  key_pair = "${var.key_pair}"
}
