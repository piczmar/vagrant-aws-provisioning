class grails {
  include apt
  apt::ppa { "ppa:webupd8team/java": }

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  exec { 'apt-get update 2':
    command => '/usr/bin/apt-get update',
    require => [ Apt::Ppa["ppa:webupd8team/java"], Package["git-core"] ],
  }

  package { ["vim",
             "curl",
             "git-core",
             "bash"]:
    ensure => present,
    require => Exec["apt-get update"],
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  package { ["oracle-java7-installer"]:
    ensure => present,
    require => Exec["apt-get update 2"],
  }

  exec {
    "accept_license":
    command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
    cwd => "/home/ubuntu",
    user => "ubuntu",
    path    => "/usr/bin/:/bin/",
    before => Package["oracle-java7-installer"],
    logoutput => true,
  }

  exec { "add_java_home":
    command => '/bin/echo "export JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /home/ubuntu/.bashrc',
  }




class pre_req {
  user { "ubuntu":
    ensure => "present",
  }

  exec { 'apt-update':
    command => 'apt-get update',
    path    => '/usr/bin'
  }->
  exec { 'install_postgres':
    command => "/bin/bash -c 'LC_ALL=en_US.UTF-8; /usr/bin/apt-get -y install postgresql'",
  }
}

stage { 'pre':
  before => Stage['main']
}

class { 'pre_req':
  stage => pre
}

package { ['postgresql-server-dev-9.3']:
  ensure  => 'installed',
  before  => Class['postgresql::server']
}

class { 'postgresql::globals':
  encoding => 'UTF8',
  locale   => 'en_US.UTF-8'
}->
class { 'postgresql::server':
  stage                   => main,
  locale                  => 'en_US.UTF-8',
  ip_mask_allow_all_users => '0.0.0.0/0',
  listen_addresses        => '*',
  ipv4acls                => ['local all all md5'],
  postgres_password       => 'secret',
  require                 => User['ubuntu']
}->
postgresql::server::db { 'databasenamedev':
  owner => 'postgres',
  user     => 'databaseuser',
  password => postgresql_password('databaseuser_password', 'databaseuser_password'),
}
postgresql::server::role { 'ubuntu':
  createdb      => true,
  login         => true,
  password_hash => postgresql_password("ubuntu", "ubuntu"),
}
#postgresql::server::role { 'marmot':
#  password_hash => postgresql_password('marmot', 'mypasswd'),
#}

postgresql::server::database_grant { 'manage db':
  privilege => 'ALL',
  db        => 'databasenamedev',
  role      => 'ubuntu',
}


}

include grails


