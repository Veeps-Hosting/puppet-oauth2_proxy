# @summary Class to install and configure an oauth2_proxy
#
# @param manage_user Should the module manage the user creation
#   Default: true
# @param manage_group Should the module manage the group creation
#   Default: true
# @param manage_service Should the module manage the systemd service
#   Default: true
# @param user The useraccount to create the files needed for the proxy
#   Default: 'oauth2'
# @param group The users group accountname
#   Default: same as user
# @param install_root The path where the proxy will be installed
#   Default: '/opt/oauth2_proxy'
# @param version The version of oauth2_proxy to install
#   Default: '7.3.0'
# @param source_base_url The base URL where the software tarball can be found
#   Default: "https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v${version}"
# @param tarball_name The name of the tarball
#   Default: "oauth2-proxy-v${version}.linux-${architecture}.tar.gz"
# @param provider Provider to use
#   Default: 'systemd'
# @param shell Shell to use for oauth2 user
#   Default: '/sbin/nologin'
# @param systemd_path Path of systemd
#   Default: '/usr/lib/systemd/system'
# @param instances A Hash of oauth2_proxy instances and its configuration
#   Default: '/usr/lib/systemd/system'
#
class oauth2_proxy (
  String           $group           = 'oauth2',
  Stdlib::Unixpath $install_root    = '/opt/oauth2_proxy',
  Optional[Hash]   $instances       = undef,
  Boolean          $manage_group    = true,
  Boolean          $manage_service  = true,
  Boolean          $manage_user     = true,
  String           $provider        = 'systemd',
  String           $version         = '7.3.0',
  Stdlib::HTTPUrl  $source_base_url = "https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v${version}",
  Optional[String] $tarball_name    = undef,
  String           $user            = 'oauth2',
) {

  # in theory, this module should work on any linux distro that uses systemd
  # but it has only been tested on el7
  case $facts[os][family] {
    'RedHat': {
      $shell = '/sbin/nologin'
      $systemd_path = '/usr/lib/systemd/system'
    }
    'Debian': {
      $shell = '/usr/sbin/nologin'
      $systemd_path = '/etc/systemd/system'
    }
    default: {
      fail("Module ${module_name} is not supported on operatingsystem ${facts[os][family]}")
    }
  }

  $real_arch = $facts[os][architecture] ? {
    'x86_64'  => 'amd64',
    'aarch64' => 'arm64',
    'armv7l'  => 'armv7',
    'armv6l'  => 'armv6',
    'armv5l'  => 'armv5',
    default   => $facts[os][architecture],
  }

  case $real_arch {
    'amd64': {}
    'arm64': {}
    'armv7': {}
    'armv6': {}
    'armv5': {}
    default: {
      fail("Module ${module_name} is not supported on architecture ${real_arch}")
    }
  }

  if $manage_user {
    user { $user:
      gid    => $group,
      system => true,
      home   => '/',
      shell  => $shell,
    }
  }

  if $manage_group {
    group { $group:
      ensure => present,
      system => true,
    }
  }

  class { 'oauth2_proxy::install':
    tarball_name => $tarball_name ? {
      true  => $tarball_name,
      default => "oauth2-proxy-v${version}.linux-${real_arch}.tar.gz",
    },
  }

  if $instances {
    create_resources('oauth2_proxy::instance', $instances)
  }

}
