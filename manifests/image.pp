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
  $image_name        = undef,
){

  file { "/etc/docker/${title}/":
    ensure  => directory,
    require => Class['docker'],
  }

  if $install_agent {
    $dockerfile_template = 'agent_Dockerfile.epp'
  } else {
    $dockerfile_template = 'no_agent_Dockerfile.epp'
  }

  $docker_files = [
    {'filename' => "Dockerfile",       'template' => $dockerfile_template},
    {'filename' => "puppet.conf",      'template' => 'puppet.conf.epp'},
    {'filename' => "local_cache.repo", 'template' => 'local_cache.repo.epp'},
    {'filename' => "yum.conf",         'template' => 'yum.conf.epp'},
    {'filename' => "gemrc",            'template' => 'gemrc.epp'}
  ]

  if $image_name {
    $actual_image_name = $image_name
  } else {
    $actual_image_name = $registry ? {
      undef   => 'centos:7',
      default => "${registry}/centos:7",
    }
  }

  $gem_source_uri = 'file:///var/cache/rubygems/'

  $docker_files.each |$docker_file|{
    file { "/etc/docker/${title}/${docker_file['filename']}":
      ensure            => file,
      content           => epp("dockeragent/${docker_file['template']}",{
        'os_major'          => $::os['release']['major'],
        'gateway_ip'        => $gateway_ip,
        'basename'          => $actual_image_name,
        'yum_cache'         => $yum_cache,
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

  file { "/etc/docker/${title}/crond.pam":
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/dockeragent/crond.pam',
  }

  docker::image { $title:
    docker_dir => "/etc/docker/${title}/",
    require    => File["/etc/docker/${title}/"],
  }
}
