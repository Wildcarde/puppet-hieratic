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

class hieratic::firewalldocker (
  $global_enable = true,
  $firewall_label = firewall,
  $firewall_enabled = false,
  $firewall_defaults = {},
  $firewall_pre_label = firewall_pre,
  $firewall_pre_enabled = false,
  $firewall_pre_defaults = {},
  $firewall_post_label = firewall_post,
  $firewall_post_enabled = false,
  $firewall_post_defaults = {},
  $firewall_ignore_labels = [''],
) {


  if(defined('firewall')
    and ($firewall_enabled or $global_enable)) {
    notify{'using hieratic iptables + docker module':}
  $docker_ignores= ['docker0',
  'DOCKER',
  'docker_gwbridge',
  '\b(?i:veth)',
  '\b(?i:br-)']

  if $firewall_ignore_labels != ['']{
    $ignores = $docker_ignores + $firewall_ignore_labels}
  else
    {$ignores = $docker_ignores}

  firewallchain {
    [ 'PREROUTING:mangle:IPv4',
      'PREROUTING:nat:IPv4',
      'FORWARD:filter:IPv4',
      'FORWARD:mangle:IPv4',
      'POSTROUTING:mangle:IPv4',
      'OUTPUT:filter:IPv4',
      'INPUT:mangle:IPv4',
      'OUTPUT:mangle:IPv4',
      'FORWARD:security:IPv4',
      'OUTPUT:nat:IPv4',
      'POSTROUTING:nat:IPv4',
      ]:
      purge  => true,

      ignore => $ignores,

  }

    Firewall {
      before  => Class['hieratic::firewall::post'],
      require => Class['hieratic::firewall::pre'],
    }

    $firewall_config = hiera_hash($firewall_label, {})

    $firewall_config_expanded = hashexpander($firewall_config,['dport','source','proto'])

    create_resources(firewall, $firewall_config_expanded, $firewall_defaults)

    class { ['hieratic::firewall::pre', 'hieratic::firewall::post']: }
  }
}
