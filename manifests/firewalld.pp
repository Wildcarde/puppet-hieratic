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
# - docker and firewalld updates by Garrett McGrath <gmcgrath@princeton.edu>
class hieratic::firewalld (
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
) {

## this is going to make some possibly heavy handed decisions
# - it will purge all rich,service, and port configurations from the default zone
# - it will munge all rules from the older firewall configuration type
# into 'rich_rule' types applied to the default zone
# - it will assume if you requested firewall rules be enabled it should act.

## need: a function that will convert a standard firewall type rule to a firewalld rich-rule
#so from:
#'comment':
#  proto: 'tcp'
#  dport: '22'
#  action: 'accept'
##to:
#'comment':
#  ensure: present
#  zone: default <will use fact to detect default.>
#  port:
#    port: 22
#    protocol: 'tcp'
#  action: 'accept'

include ::firewalld ## import firewalld if we've gotten this far

  if(defined('firewalld')
    and ($firewall_enabled or $global_enable)) {


    notify{"using hieratic firewalld module, zone: ${::firewalld_default_zone}":}

    firewalld_zone{$::firewalld_default_zone:
      purge_rich_rules => true,
      }

    $firewall_config = hiera_hash($firewall_label, {})

    $firewall_config_expanded = hashexpander($firewall_config,['dport','source','proto'])

    notify{'converting rules': message => "${$firewall_config_expanded}",}

    $firewalld_converted_config = fwtofwd($firewall_config_expanded, $::firewalld_default_zone)

    notify{'converted hash': message => "${$firewalld_converted_config}",}

    #create_resources(firewalld_rich_rule, $firewalld_config)
    $firewalld_converted_config.each | String $key, Hash $attrs| {
      firewalld_rich_rule { $key:
      *       => $attrs,
      require => Service['firewalld'],
      notify  => Exec['firewalld::reload'],
      }
    }

    class { ['hieratic::firewalld::pre', 'hieratic::firewalld::post']: }
  }
}
