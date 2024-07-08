# @summary Class to install and configure an oauth2_proxy
#   This class should be considered private.
#
class oauth2_proxy::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $base    = regsubst($oauth2_proxy::tarball_name, '(\w+).tar.gz$', '\1')

  include ::archive
  archive { $oauth2_proxy::tarball_name:
    ensure       => present,
    source       => "${oauth2_proxy::source_base_url}/${oauth2_proxy::tarball_name}",
    path         => "${oauth2_proxy::install_root}/${oauth2_proxy::tarball_name}",
    creates      => "${oauth2_proxy::install_root}/${base}",
    extract      => true,
    extract_path => $oauth2_proxy::install_root,
    user         => $oauth2_proxy::user,
  }

  file { $oauth2_proxy::install_root:
    ensure => directory,
    owner  => $oauth2_proxy::user,
    group  => $oauth2_proxy::group,
    mode   => '0755',
  }

  file { "${oauth2_proxy::install_root}/bin":
    ensure => link,
    owner  => $oauth2_proxy::user,
    group  => $oauth2_proxy::group,
    target => "${oauth2_proxy::install_root}/${base}",
  }

  file { '/etc/oauth2_proxy':
    ensure => directory,
    owner  => $oauth2_proxy::user,
    group  => $oauth2_proxy::group,
    mode   => '0755',
  }

  file { '/var/log/oauth2_proxy':
    ensure => directory,
    owner  => $oauth2_proxy::user,
    group  => $oauth2_proxy::group,
    mode   => '0775',
  }

  case $oauth2_proxy::provider {
    'systemd': {
      file { "${oauth2_proxy::systemd_path}/oauth2_proxy@.service":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/oauth2_proxy@.service.erb"),
      }
    }
    default: {}
  }
}
