class php::pecl {
  include php

  # TBD: will be added later...

  # install xdebug
  file { "/etc/php5/conf.d/xdebug.ini":
    ensure => present,
    source => "/vagrant/manifests/xdebug.ini",
    require => Package["php5-xdebug"],
  }
}
