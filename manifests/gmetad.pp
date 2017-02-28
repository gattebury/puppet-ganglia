# == Class: ganglia::gmetad
#
class ganglia::gmetad(
  $all_trusted                     = false,
  $clusters                        = [
    { 'name' => 'my cluster', 'address' => 'localhost' },
  ],
  $gridname                        = undef,
  $rras                            = $::ganglia::params::rras,
  $trusted_hosts                   = [],
  $server_threads                  = '4',
  $gmetad_package_name             = $::ganglia::params::gmetad_package_name,
  $gmetad_package_ensure           = 'present',
  $gmetad_service_name             = $::ganglia::params::gmetad_service_name,
  $gmetad_service_config           = $::ganglia::params::gmetad_service_config,
  $gmetad_user                     = $::ganglia::params::gmetad_user,
  $gmetad_case_sensitive_hostnames =
    $::ganglia::params::gmetad_case_sensitive_hostnames,
  $gmetad_status_command           = $::ganglia::params::gmetad_status_command,
) inherits ganglia::params {
  validate_bool($all_trusted)
  ganglia_validate_clusters($clusters)
  validate_string($gridname)
  ganglia_validate_rras($rras)
  validate_array($trusted_hosts)
  validate_string($gmetad_package_name)
  validate_string($gmetad_package_ensure)
  validate_string($gmetad_service_name)
  validate_string($gmetad_service_config)
  validate_string($gmetad_user)
  validate_integer($gmetad_case_sensitive_hostnames, 1, 0)
  validate_string($gmetad_status_command)

  if ($::ganglia::params::gmetad_status_command) {
    $hasstatus = false
  } else {
    $hasstatus = true
  }

  if versioncmp($::puppetversion, '3.6.0') > 0 {
    package { $gmetad_package_name:
      ensure        => $gmetad_package_ensure,
      allow_virtual => false,
      notify        => Service[$gmetad_service_name],
    }
  } else {
    package { $gmetad_package_name:
      ensure => $gmetad_package_ensure,
      notify => Service[$gmetad_service_name],
    }
  }

  Package[$gmetad_package_name] ->
  file { $gmetad_service_config:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($::ganglia::params::gmetad_service_erb),
  } ~>
  service { $gmetad_service_name:
    ensure     => running,
    hasstatus  => $hasstatus,
    hasrestart => true,
    enable     => true,
    status     => $gmetad_status_command,
  }
}
