output bastion_ip {
  value = "${openstack_compute_floatingip_v2.bastion.address}"
}
