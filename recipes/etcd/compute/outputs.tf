output bastion_fip {
  value = "${openstack_compute_floatingip_v2.bastion.address}"
}
