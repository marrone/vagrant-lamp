class tools {

  # package install list
  $packages = [
    "curl",
    "vim",
    "htop",
    "wget"
  ]

  # install packages
  package { $packages:
    ensure => present,
    require => Exec["apt-get update"]
  }
}
