# Define: mcollective::plugins::plugin
#
#   Manage the files for MCollective plugins.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#     mcollective::plugins::plugin { 'package':
#       ensure      => present,
#       type        => 'agent',
#       ddl         => true,
#       application => false,
#     }
#
define mcollective::plugins::plugin(
  $type,
  $ensure      = present,
  $ddl         = false,
  $application = false,
  $agent       = true,
  $plugin_base = $mcollective::params::plugin_base,
  $module_source = 'puppet:///modules/mcollective/plugins'
) {

  include mcollective::params

  File {
    owner => '0',
    group => '0',
    mode  => '0644',
  }

  if $plugin_base == '' {
    $plugin_base_real = $mcollective::params::plugin_base
  } else {
    $plugin_base_real = $plugin_base
  }

  if ($ddl == true or $application == true) and $type != 'agent' {
    fail('DDLs and Applications only apply to Agent plugins')
  }

  case $type {
    'agent': {
      if $name == 'registration-monitor' {
        $source = "${module_source}/${type}/${name}/registration.rb"
      } else {
        $source = "${module_source}/${type}/${name}/${type}/${name}.rb"
      }
    }
    'registration': {
      $source = "${module_source}/${type}/${name}.rb"
    }
    'facts': {
      $source = "${module_source}/${type}/facter/${name}.rb"
    }
  }

  if $agent {
    file { "${plugin_base_real}/${type}/${name}.rb":
      ensure => $ensure,
      source => $source,
      notify => Class['mcollective::server::service'],
    }
  }

  if $ddl {
    file { "${plugin_base_real}/${type}/${name}.ddl":
      ensure => $ensure,
      source => "${module_source}/${type}/${name}/${type}/${name}.ddl",
      notify => Class['mcollective::server::service'],
    }
  }

  if $application {
    file { "${plugin_base_real}/application/${name}.rb":
      ensure => $ensure,
      source => "${module_source}/agent/${name}/application/${name}.rb",
      notify => Class['mcollective::server::service'],
    }
  }

}
