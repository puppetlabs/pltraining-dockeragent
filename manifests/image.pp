# This defined type sets up the docker environment and image(s)
# This should ONLY be run from the main dockeragent class

define dockeragent::image (
  $registry = undef,
  $yum_server = 'master.puppetlabs.vm',
  $yum_cache = false,
  $install_agent = true,
  $lvm_bashrc = false,
){

  file { "/etc/docker/${title}/":
    ensure  => directory,
    require => Class['docker'],
  }

  $docker_files = [
    "Dockerfile",
    "base_cache.repo",
    "epel_cache.repo",
    "puppet.conf",
    "updates_cache.repo",
    "yum.conf",
  ]
  $image_name = $registry ? {
    undef   => 'centos:7',
    default => "${registry}/centos:7",
  }
  $docker_files.each |$docker_file|{
    file { "/etc/docker/${title}/${docker_file}":
      ensure            => file,
      content           => epp("dockeragent/${docker_file}.epp",{
        'os_major'      => $::os['release']['major'],
        'yum_server'    => $yum_server,
        'basename'      => $image_name,
        'yum_cache'     => $yum_cache,
        'install_agent' => $install_agent,
        'lvm_bashrc'    => $lvm_bashrc,
        }),
    }
  }

  if $lvm_bashrc {
    file { "/etc/docker/${title}/bashrc":
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/dockeragent/bashrc',
    }
    file { "/etc/docker/${title}/bash_profile":
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/dockeragent/bash_profile',
    }
  }

  file { "/etc/docker/${title}/download_catalogs.sh":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/dockeragent/download_catalogs.sh',
  }

  file { "/etc/docker/${title}/refresh-mcollective-metadata":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/dockeragent/refresh-mcollective-metadata',
  }

  file { "/etc/docker/${title}/root.cron":
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/dockeragent/root.cron',
  }
  
  file { "/etc/docker/${title}/crond.pam":
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/dockeragent/crond.pam',
  }

  docker::image {$title:
    docker_dir => "/etc/docker/${title}/",
    require    => File["/etc/docker/${title}/"],
  }
}
