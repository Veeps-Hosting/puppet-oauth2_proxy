# @summary Class to install and configure an oauth2_proxy
#   This class should be considered private.
#
class oauth2_proxy::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $base    = regsubst($oauth2_proxy::tarball_name, '(\w+).tar.gz$', '\1')

  include ::archive
  $tarfile = "${oauth2_proxy::install_root}/download/${oauth2_proxy::tarball_name}"
  archive { $oauth2_proxy::tarball_name:
    ensure       => present,
    source       => "${oauth2_proxy::source_base_url}/${oauth2_proxy::tarball_name}",
    path         => $tarfile,
    extract      => true,
    extract_path => $oauth2_proxy::install_root,
    user         => $oauth2_proxy::user,
    cleanup      => $oauth2_proxy::delete_tarball,
  }
  ~> file { $tarfile: }

  file {
    default:
      owner  => $oauth2_proxy::user,
      group  => $oauth2_proxy::group,
      mode   => '0755',
      ;
    $oauth2_proxy::install_root:
      ensure => directory,
      ;
    "${oauth2_proxy::install_root}/download":
      ensure  => directory,
      # Even with delete_tarball true, only keep current tarball in this directory
      recurse => true,
      purge   => true,
      ;
    "${oauth2_proxy::install_root}/bin":
      ensure => link,
      target => "${oauth2_proxy::install_root}/${base}",
      ;
    '/etc/oauth2_proxy':
      ensure => directory,
      ;
    '/var/log/oauth2_proxy':
      ensure => directory,
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
