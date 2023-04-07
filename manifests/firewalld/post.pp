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

class hieratic::firewalld::post {
  Firewalld_rich_rule {
     before => undef,
  }
  if(defined('firewalld')
    and ($hieratic::firewall::firewall_post_enabled
      or $hieratic::firewall::global_enable)) {

    $firewall_config = hiera_hash($hieratic::firewall::firewall_post_label,
        $hieratic::firewall::firewall_post_defaults)

    notify{"converting: POST ${firewall_config}":}

    $firewalld_config = fwtofwd($firewall_config, $::firewalld_default_zone)

    create_resources(firewalld_rich_rule, $firewalld_config)
  }
}
