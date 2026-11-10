# Changelog

All notable changes to this project will be documented in this file.

## Release 1.0.2
Bugfix and compatibility release.

**Bugfixes**

* `oauth2_proxy::install`: the archive resource now has `creates` (the extracted binary). Without it every Puppet run re-downloaded the release and re-extracted it over the live binary, and a host reset mid-extract left a truncated binary.
* `oauth2_proxy::instance`: the service now also subscribes to the `bin` symlink, so a version bump restarts the service instead of leaving the old binary running in memory.
* `oauth2_proxy::install`: the `bin` symlink now requires the archive, instead of relying on manifest order.

**Other changes**

* Default `version` raised from 7.3.0 to 7.15.6 (latest upstream release at the time of writing).
* Dependency bounds widened: puppet below 9.0.0, puppetlabs/stdlib below 11.0.0, puppet/archive below 10.0.0.

## Release 1.0.1
Minor bugfix release to have parameter 'version' before it's used in 'source_base_url'.

## Release 1.0.0
Main line version of upstream Oauth Proxy upgraded to v7.3.0
Removed params class in favour of proper params in init.pp, meaning better upgradability and configurability
Tested as working with recent Ubuntu LTS versions 20.04 and 22.04

**Features**

**Bugfixes**

**Known Issues**
