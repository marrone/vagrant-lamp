class mysql {

  # root mysql password
  $mysqlpw = "d3v0p5"

  # install mysql server
  package { "mysql-server":
    ensure => present,
    require => Exec["apt-get update"]
  }

  #start mysql service
  service { "mysql":
    ensure => running,
    require => Package["mysql-server"],
  }

  # allow connections from host
  exec { "add-external-mysql-user-login":
    require => Service["mysql"],
    command => "mysql -uroot < /vagrant/manifests/host_login.sql"
  }
  exec { "open-external-mysql-connections":
    require => Service["mysql"],
    command => "sed -i .bak 's/\\(skip-external-locking\\)/#\\1/g' /etc/mysql/my.cnf && sed -i .bak 's/\\(bind-address\\)/#\\1/g' /etc/mysql/my.cnf && /etc/init.d/mysql restart"
  }

  # set mysql password
  #exec { "set-mysql-password":
    #unless => "mysqladmin -uroot -p$mysqlpw status",
    #command => "mysqladmin -uroot password $mysqlpw",
    #require => Service["mysql"],
  #}
}
