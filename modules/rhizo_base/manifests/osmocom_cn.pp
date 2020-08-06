# Class: rhizo_base::osmocom_cn
#
# This module manages a network-in-a-box installation of the osmocom
# cellular core network components.
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class rhizo_base::osmocom_cn {
  $network_name    = $rhizo_base::network_name
  $auth_policy     = $rhizo_base::auth_policy
  $lac             = $rhizo_base::lac
  $ms_max_power    = $rhizo_base::ms_max_power
  $max_power_red   = $rhizo_base::max_power_red
  $gsm_band        = $rhizo_base::gsm_band
  $mcc             = $rhizo_base::mcc
  $mnc             = $rhizo_base::mnc
  $arfcn_0_A       = $rhizo_base::arfcn_0_A
  $arfcn_0_B       = $rhizo_base::arfcn_0_B
  $arfcn_C         = $rhizo_base::arfcn_C
  $arfcn_D         = $rhizo_base::arfcn_D
  $arfcn_E         = $rhizo_base::arfcn_E
  $arfcn_F         = $rhizo_base::arfcn_F
  $bts2_ip_address = $rhizo_base::bts2_ip_address
  $bts3_ip_address = $rhizo_base::bts3_ip_address
  $smsc_password   = $rhizo_base::smsc_password
  $smpp_password   = $rhizo_base::smpp_password
  $mncc_codec      = $rhizo_base::mncc_codec
  $gprs            = $rhizo_base::gprs
  $mncc_ip_address = $rhizo_base::mncc_ip_address
  $mgw_dataplane_ip_address  = $rhizo_base::ran_ip_address
  $mgw_controlplane_ip_address  = hiera('rhizo::osmo_cn_local_ip_address')
  $msc_ip_address  = hiera('rhizo::osmo_cn_local_ip_address')
  $vpn_ip_address  = hiera('rhizo::vpn_ip_address')
  $sgsn_ip_address = hiera('rhizo::sgsn_ip_address')
  $ggsn_ip_address = hiera('rhizo::ggsn_ip_address')
  $repo            = hiera('rhizo::osmo_repo', 'latest')

  if $mncc_codec == "AMR" {
    $phys_chan = "TCH/H"
  } else {
    $phys_chan = "TCH/F"
  }

  $bsc_version = $repo ? {
    'latest'    => '1.6.1',
    'nightly'   => 'latest',
    default     => '1.6.1',
  }
  package {  [ 'osmo-bsc' ]:
    ensure   => $bsc_version,
    require  => Class['rhizo_base::apt'],
    notify   => [ Exec['notify-nitb'] ],
  }
  service { 'osmo-bsc':
    enable  => true,
    ensure  => 'running',
    require => Package['osmo-bsc'],
  }

  $msc_version = $repo ? {
    'latest'    => '1.6.2',
    'nightly'   => 'latest',
    default     => '1.6.2',
  }
  package {  [ 'osmo-msc' ]:
    ensure   => $msc_version,
    require  => Class['rhizo_base::apt'],
    notify   => [ Exec['notify-nitb'] ],
  }
  service { 'osmo-msc':
    enable  => true,
    ensure  => 'running',
    require => Package['osmo-msc'],
  }

  $mgw_version = $repo ? {
    'latest'    => '1.7.0',
    'nightly'   => 'latest',
    default     => '1.7.0',
  }
  package {  [ 'osmo-mgw' ]:
    ensure   => $mgw_version,
    require  => Class['rhizo_base::apt'],
    notify   => [ Exec['notify-nitb'] ],
  }
  service { 'osmo-mgw':
    enable  => true,
    ensure  => 'running',
    require => Package['osmo-mgw'],
  }

  $hlr_version = $repo ? {
    'latest'    => '1.2.0',
    'nightly'   => 'latest',
    default     => '1.2.0',
  }
  package {  [ 'osmo-hlr' ]:
    ensure   => $hlr_version,
    require  => Class['rhizo_base::apt'],
    notify   => [
      Exec['notify-nitb'],
      Exec['hlr_pragma_wal'],
    ],
  }
  service { 'osmo-hlr':
    enable  => true,
    ensure  => 'running',
    require => Package['osmo-hlr'],
  }

  $stp_version = $repo ? {
    'latest'    => '1.2.1',
    'nightly'   => 'latest',
    default     => '1.2.1',
  }
  package {  [ 'osmo-stp' ]:
    ensure   => $stp_version,
    require  => Class['rhizo_base::apt'],
    notify   => [ Exec['notify-nitb'] ],
  }
  service { 'osmo-stp':
    enable  => true,
    ensure  => 'running',
    require => Package['osmo-stp'],
  }

  $sip_connector_version = $repo ? {
    'latest'    => '1.3.2',
    'nightly'   => 'latest',
    default     => '1.3.0',
  }
  package {  [ 'osmo-sip-connector' ]:
    ensure   => $sip_connector_version,
    require  => Class['rhizo_base::apt'],
    notify   => [ Exec['notify-nitb'] ],
  }
  service { 'osmo-sip-connector':
    enable  => true,
    ensure  => 'running',
    require => Package['osmo-sip-connector'],
  }

  $meas_utils_version = $repo ? {
    'latest'    => '1.6.1',
    'nightly'   => 'latest',
    default     => '1.6.1',
  }
  package { [ 'osmo-bsc-meas-utils' ]:
    ensure   => $meas_utils_version,
    require  => Class['rhizo_base::apt'],
  }

  package { [ 'libosmocore-utils' ]:
    ensure   => 'latest',
    require  => Class['rhizo_base::apt'],
  }

  if ($gprs == "active") {
    $sgsn_version = $repo ? {
      'latest'    => '1.6.1',
      'nightly'   => 'latest',
      default     => '1.6.1',
    }
    package {  [ 'osmo-sgsn' ]:
      ensure   => $sgsn_version,
      require  => Class['rhizo_base::apt'],
      notify   => [ Exec['notify-nitb'] ],
    }
    service { 'osmo-sgsn':
      enable  => true,
      ensure  => 'running',
      require => Package['osmo-sgsn'],
    }

    $ggsn_version = $repo ? {
      'latest'    => '1.5.0',
      'nightly'   => 'latest',
      default     => '1.5.0',
    }
    package {  [ 'osmo-ggsn' ]:
      ensure   => $ggsn_version,
      require  => Class['rhizo_base::apt'],
      notify   => [ Exec['notify-nitb'] ],
    }
    service { 'osmo-ggsn':
      enable  => true,
      ensure  => 'running',
      require => Package['osmo-ggsn'],
    }
  }

  # Setup core network config files
  unless hiera('rhizo::local_osmocom_cfg') == "1" {
    file { '/etc/osmocom/osmo-bsc.cfg':
      content => template('rhizo_base/osmo-bsc.cfg.erb'),
      require => Package['osmo-bsc'],
      notify  => Exec['notify-nitb'],
    }
    file { '/etc/osmocom/osmo-msc.cfg':
      content => template('rhizo_base/osmo-msc.cfg.erb'),
      require => Package['osmo-msc'],
      notify  => Exec['notify-nitb'],
    }
    file { '/etc/osmocom/osmo-mgw.cfg':
      content => template('rhizo_base/osmo-mgw.cfg.erb'),
      require => Package['osmo-mgw'],
      notify  => Exec['notify-nitb'],
    }
    file { '/etc/osmocom/osmo-hlr.cfg':
      content => template('rhizo_base/osmo-hlr.cfg.erb'),
      require => Package['osmo-hlr'],
      notify  => Exec['notify-nitb'],
    }
    file { '/etc/osmocom/osmo-stp.cfg':
      content => template('rhizo_base/osmo-stp.cfg.erb'),
      require => Package['osmo-stp'],
      notify  => Exec['notify-nitb'],
    }
    file { '/etc/osmocom/osmo-sip-connector.cfg':
      content => template('rhizo_base/osmo-sip-connector.cfg.erb'),
      require => Package['osmo-sip-connector'],
      notify  => Exec['notify-nitb'],
    }

    if ($gprs == "active") {
      file { '/etc/osmocom/osmo-sgsn.cfg':
        content => template('rhizo_base/osmo-sgsn.cfg.erb'),
        require => Package['osmo-sgsn'],
        notify  => Exec['notify-nitb'],
      }
      file { '/etc/osmocom/osmo-ggsn.cfg':
        content => template('rhizo_base/osmo-ggsn.cfg.erb'),
        require => Package['osmo-ggsn'],
        notify  => Exec['notify-nitb'],
      }
      file { '/etc/osmocom/make_sgsn_acl_config':
        content => template('rhizo_base/make_sgsn_acl_config.erb'),
        mode => "0750",
      }
    }
  }

  file { '/usr/local/bin/vty':
    source  => 'puppet:///modules/rhizo_base/vty',
    owner   => 'root',
    mode    => '0755',
  }

  exec { 'hlr_pragma_wal':
    command     =>
    '/usr/bin/sqlite3 /var/lib/osmocom/hlr.sqlite3 "PRAGMA journal_mode=wal;"',
    require     => Class['rhizo_base::packages'],
    refreshonly => true,
  }

  exec { 'notify-nitb':
    command     => '/bin/echo 1 > /tmp/OSMO-dirty',
    refreshonly => true,
  }

}
