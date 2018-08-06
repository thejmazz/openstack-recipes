output bastion_ip {
  value = "${openstack_compute_floatingip_v2.bastion.address}"
}

output controller_ip {
  value = "${openstack_compute_floatingip_v2.controller.address}"
}
