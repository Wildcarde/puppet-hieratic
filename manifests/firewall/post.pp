# == Class: hieratic
#
# Internal class- this should be called through Hieratic, not directly.
#
# === Authors
#
# Robert Hafner <tedivm@tedivm.com>
#
# === Copyright
#
# Copyright 2015 Robert Hafner
#
class hieratic::firewall::post 
(
    $global_enable = true,
  $firewall_label = firewall,
  $firewall_enabled = false,
  $firewall_defaults = {},
  $firewall_pre_label = firewall_pre,
  $firewall_pre_enabled = false,
  $firewall_pre_defaults = {},
  $firewall_post_label = firewall_post,
  $firewall_post_enabled = false,
  $firewall_post_defaults = {}
){
  Firewall {
    before => undef,
  }
  if(defined('firewall')
    and ($firewall_post_enabled
      or $global_enable)) {
    create_resources(firewall,
      hashexpander(hiera_hash($firewall_post_label,
        $firewall_post_defaults),['dport','source','proto']))
  }
}
