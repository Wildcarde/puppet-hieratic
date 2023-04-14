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

class hieratic::firewall::post {
  Firewall {
    before => undef,
  }
  if(defined('firewall')
    and ($hieratic::firewall::firewall_post_enabled
      or $hieratic::firewall::global_enable)) {
    create_resources(firewall,
      hashexpander(hiera_hash($hieratic::firewall::firewall_post_label,
        $hieratic::firewall::firewall_post_defaults),['dport','source','proto']))
  }
}
