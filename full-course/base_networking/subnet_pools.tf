resource "openstack_networking_subnetpool_v2" "public" {
  name = "${var.project_name}_public"
  description = "Subnet pool to be used for subnets attached to router with an external gateway"

  prefixes = [ "10.100.0.0/16" ]

  default_prefixlen = "24"
  min_prefixlen = "16"
  max_prefixlen = "32"
}

resource "openstack_networking_subnetpool_v2" "private" {
  name = "${var.project_name}_private"
  description = "Subnet pool to be used for subnets attached to router with no external gateway"

  prefixes = [ "10.110.0.0/16" ]

  default_prefixlen = "24"
  min_prefixlen = "16"
  max_prefixlen = "32"
}

resource "openstack_networking_subnetpool_v2" "airgap" {
  name = "${var.project_name}_airgap"
  description = "Subnet pool to be used for subnets with no (direct) access to public internet"

  prefixes = [ "10.120.0.0/16" ]

  default_prefixlen = "24"
  min_prefixlen = "16"
  max_prefixlen = "32"
}
