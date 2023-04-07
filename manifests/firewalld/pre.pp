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

class hieratic::firewalld::pre {
  Firewalld_rich_rule {
    require => undef,
  }
  if(defined('firewalld')
    and ($hieratic::firewall::firewall_pre_enabled
      or $hieratic::firewall::global_enable)) {

    $firewall_config = hiera_hash($hieratic::firewall::firewall_pre_label,
        $hieratic::firewall::firewall_pre_defaults)

    notify{"converting: PRE ${firewall_config}":}

    $firewalld_config = fwtofwd($firewall_config, $::firewalld_default_zone)

    create_resources(firewalld_rich_rule, $firewalld_config)
  }
}
