output web_floating_ip {
  value = "${openstack_compute_floatingip_v2.web.address}"
}
