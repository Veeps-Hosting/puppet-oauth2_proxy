# @summary Defined type to configure a oauth2_proxy instance
#
# @param config Hash with configuration parameter for oauth2_proxy
#   Details can be founce here https://oauth2-proxy.github.io/oauth2-proxy/docs/6.1.x/configuration/overview
#
define oauth2_proxy::instance (
  Hash    $config,
) {
  file { "/etc/oauth2_proxy/${title}.conf":
    ensure  => file,
    owner   => $oauth2_proxy::user,
    group   => $oauth2_proxy::group,
    mode    => '0440',
    content => template("${module_name}/oauth2_proxy.conf.erb"),
  }

  file { "/var/log/oauth2_proxy/${title}.log":
    ensure => file,
    owner  => $oauth2_proxy::user,
    group  => $oauth2_proxy::group,
    mode   => '0644',
  }

  case $oauth2_proxy::provider {
    'debian': {
      file { "/etc/init.d/oauth2_proxy@${title}":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/oauth2_proxy.initd.erb"),
      }
    }
    'upstart': {
      file { "/etc/init/oauth2_proxy@${title}.conf":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/oauth2_proxy.init.erb"),
      }
    }
    default: {}
  }

  if $oauth2_proxy::manage_service {
    case $oauth2_proxy::provider {
      'debian': {
        service { "oauth2_proxy@${title}":
          ensure    => 'running',
          enable    => true,
          subscribe => File["/etc/init.d/oauth2_proxy@${title}", "/etc/oauth2_proxy/${title}.conf", "${oauth2_proxy::install_root}/bin"],
          provider  => $oauth2_proxy::provider,
        }
      }
      'upstart': {
        service { "oauth2_proxy@${title}":
          ensure    => 'running',
          enable    => true,
          subscribe => File["/etc/init/oauth2_proxy@${title}.conf", "/etc/oauth2_proxy/${title}.conf", "${oauth2_proxy::install_root}/bin"],
          provider  => $oauth2_proxy::provider,
        }
      }
      'systemd': {
        service { "oauth2_proxy@${title}":
          ensure    => 'running',
          enable    => true,
          # Without this, a version bump (which changes the bin symlink's target,
          # see oauth2_proxy::install) silently leaves the old binary running in
          # memory until an unrelated config change or a reboot.
          subscribe => File["/etc/oauth2_proxy/${title}.conf", "${oauth2_proxy::install_root}/bin"],
          provider  => $oauth2_proxy::provider,
        }
      }
      default: {}
    }
  }
}
