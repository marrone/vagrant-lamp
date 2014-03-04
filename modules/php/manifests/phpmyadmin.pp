class php::phpmyadmin {

  package { phpmyadmin:
    ensure => installed,
    require => Package['php5', 'mysql-server']
  }

  # Enable access via /phpmyadmin
  # This assumes apache is installed somewhere else in the Puppet manifests
  file { '/etc/apache2/sites-enabled/phpmyadmin':
    ensure  => 'present',
    content => 'include /etc/phpmyadmin/apache.conf',
    mode    =>  644,
    require => [
      Package["libapache2-mod-php5", 'phpmyadmin']
    ]   
  }

  # Remove config if it does not include auto-login options
  exec { 'remove-non-autologin-config':
    require => Service["apache2"],
    command => "sed -i 's/\\/\\/\\(.*AllowNoPassword.*\\)/\\1/g' /etc/phpmyadmin/config.inc.php",
  }
}
