# This defined type sets up the docker environment and image(s)
# This should ONLY be run from the main dockeragent class

define dockeragent::image (
  $registry          = undef,
  $yum_cache         = false,
  $gateway_ip        = undef,
  $install_agent     = true,
  $lvm_bashrc        = false,
  $install_dev_tools = false,
  $learning_user     = false,
){

  file { "/etc/docker/${title}/":
    ensure  => directory,
    require => Class['docker'],
  }

  $docker_files = [
    "Dockerfile",
    "puppet.conf",
    "local_cache.repo",
    "yum.conf",
    "gemrc",
  ]
  $image_name = $registry ? {
    undef   => 'centos:7',
    default => "${registry}/centos:7",
  }
  $gem_source_uri = $gateway_ip ? {
    undef   => 'file:///var/cache/rubygems/',
    default => "http://${gateway_ip}:6789",
  }

  $docker_files.each |$docker_file|{
    file { "/etc/docker/${title}/${docker_file}":
      ensure            => file,
      content           => epp("dockeragent/${docker_file}.epp",{
        'os_major'          => $::os['release']['major'],
        'gateway_ip'        => $gateway_ip,
        'basename'          => $image_name,
        'yum_cache'         => $yum_cache,
        'install_agent'     => $install_agent,
        'lvm_bashrc'        => $lvm_bashrc,
        'install_dev_tools' => $install_dev_tools,
        'learning_user'     => $learning_user,
        'gem_source_uri'    => $gem_source_uri,
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
