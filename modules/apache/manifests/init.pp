class apache {

  # install apache
  package { "apache2":
    ensure => present,
    require => Exec["apt-get update"]
  }

  file { "/etc/apache2/apache2.conf":
    ensure => present,
    require => Package["apache2"],
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
  # ensure the include module is loaded
  file { "/etc/apache2/mods-enabled/include.load":
    ensure => link,
    target => "/etc/apache2/mods-available/include.load",
    require => Package["apache2"]
  }
  # turn off EnableSendfile
  exec { "disable-apache-sendfile":
    command => "echo 'EnableSendfile Off' >> /etc/apache2/apache2.conf",
    unless => "grep '^EnableSendfile Off' /etc/apache2/apache2.conf",
    require => File["/etc/apache2/apache2.conf"]
  }

  # setup fancy indexing project
  exec { "pull-fancyindexing-repo":
    command => "git clone https://github.com/marrone/Apaxy.git /vagrant_projects/webserver",
    unless => "find /vagrant_projects/webserver -type d",
    require => Package["git"]
  }
  file { "/vagrant_projects/webserver":
    ensure => directory,
    require => Exec["pull-fancyindexing-repo"]
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
  file {"/vagrant_projects/_logs":
    ensure => directory,
    before => File["/etc/apache2/sites-enabled/000-default"]
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
    require => [Package["apache2"], Exec["disable-apache-sendfile"]],
    subscribe => [
      File["/etc/apache2/mods-enabled/rewrite.load"],
      File["/etc/apache2/sites-available/vagrant_webroot"]
    ],
  }
}
