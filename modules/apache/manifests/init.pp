class apache {

  # install apache
  package { "apache2":
    ensure => present,
    require => Exec["apt-get update"]
  }

  # ensures that mod_rewrite is loaded and modifies the default configuration file
  file { "/etc/apache2/mods-enabled/rewrite.load":
    ensure => link,
    target => "/etc/apache2/mods-available/rewrite.load",
    require => Package["apache2"]
  }
  # ensures that vhost_alias is loaded and modifies the default configuration file
  file { "/etc/apache2/mods-enabled/vhost_alias.load":
    ensure => link,
    target => "/etc/apache2/mods-available/vhost_alias.load",
    require => Package["apache2"]
  }

  # create directory
  file {"/etc/apache2/sites-enabled":
    ensure => directory,
    recurse => true,
    purge => true,
    force => true,
    before => File["/etc/apache2/sites-enabled/000-default"],
    require => Package["apache2"],
  }

  # create apache config from main vagrant manifests
  file { "/etc/apache2/sites-available/vagrant_webroot":
    ensure => present,
    source => "/vagrant/manifests/vagrant_webroot",
    require => Package["apache2"],
  }

  # symlink apache site to the site-enabled directory
  file { "/etc/apache2/sites-enabled/000-default":
    ensure => link,
    target => "/etc/apache2/sites-available/vagrant_webroot",
    require => File["/etc/apache2/sites-available/vagrant_webroot"],
    notify => Service["apache2"],
  }

  # create additional vhosts for local sites
  # blackjack
  file { "/etc/apache2/sites-available/blackjack_vhost":
    ensure => present,
    source => "/vagrant/manifests/blackjack_vhost",
    require => Package["apache2"],
  }
  file { "/etc/apache2/sites-enabled/blackjack_vhost":
    ensure => link,
    target => "/etc/apache2/sites-available/blackjack_vhost",
    require => File["/etc/apache2/sites-available/blackjack_vhost"],
    notify => Service["apache2"],
  }

  # starts the apache2 service once the packages installed, and monitors changes to its configuration files and reloads if nesessary
  service { "apache2":
    ensure => running,
    require => Package["apache2"],
    subscribe => [
      File["/etc/apache2/mods-enabled/rewrite.load"],
      File["/etc/apache2/sites-available/vagrant_webroot"]
    ],
  }
}
