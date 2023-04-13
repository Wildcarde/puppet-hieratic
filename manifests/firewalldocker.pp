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
### new purge behavior needs to be implemented here:
#this nuclear option works regardless - must be disabled.
    #resources { 'firewall':
    #  purge => true
    #}

#workaround details found at: https://tickets.puppetlabs.com/browse/MODULES-2314
  # Workaround:
  # 1) Purge unmanaged firewallchain resources:
  #this seems to cause issues with internal chains which will need to be protected actively.
  #resources { 'firewallchain':
  #  purge => true,
  #}

  #list of internal chains rhel 7 (and likely 6)
  #$internalchains = ['INPUT:filter:IPv6','OUTPUT:filter:IPv6','INPUT:filter:IPv4','INPUT:nat:IPv4',
  #'INPUT:security:IPv4','FORWARD:filter:IPv6',
  #'OUTPUT:security:IPv4','INPUT:filter:ethernet','OUTPUT:filter:ethernet','FORWARD:filter:ethernet']
  #firewallchain { $internalchains:
  #  purge  => true,
  #
  #}

  #if $firewall_enable_docker{
  #  firewallchain {
  #    [ 'DOCKER:filter:IPv4',
  #      'DOCKER-ISOLATION:filter:IPv4',
  #      'DOCKER-ISOLATION-STAGE-1:filter:IPv4',
  #      'DOCKER-ISOLATION-STAGE-2:filter:IPv4',
  #      'DOCKER-INGRESS:filter:IPv4',
  #      'DOCKER:nat:IPv4',
  #      'DOCKER-INGRESS:nat:IPv4',
  #      'DOCKER-USER:filter:IPv4',
  #      ]:
  #    purge => false,
  #  }
  $docker_ignores= ['docker0',
  'DOCKER',
  'docker_gwbridge',
  '\b(?i:veth)',
  '\b(?i:br-)']
  #interfaces named br- 'should' ignore all default docker compose netoworks (i hope)
  #}
  #else{
  #firewallchain {
  #  [ 'DOCKER:filter:IPv4',
  #    'DOCKER-ISOLATION:filter:IPv4',
  #    'DOCKER-ISOLATION-STAGE-1:filter:IPv4',
  #    'DOCKER-ISOLATION-STAGE-2:filter:IPv4',
  #    'DOCKER-INGRESS:filter:IPv4',
  #    'DOCKER:nat:IPv4',
  #    'DOCKER-INGRESS:nat:IPv4',
  #    'DOCKER-USER:filter:IPv4',
  #    ]:
  #  purge => true,
  #}
    #}
  # 2) Explicitly specify a managed list of firewallchains, to purge:
  #

  $ignores = concat($docker_ignores,$firewall_ignore_labels)
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
    create_resources(firewall, $firewall_config, $firewall_defaults)

    class { ['hieratic::firewall::pre', 'hieratic::firewall::post']: }
  }
}
