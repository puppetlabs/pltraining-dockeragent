# Set up docker images

class dockeragent (
  $create_agent_image    = true,
  $create_no_agent_image = false,
  $registry              = undef,
  $yum_server            = 'master.puppetlabs.vm',
  $yum_cache             = false,
  $lvm_bashrc            = false,
  $install_dev_tools     = false,
  $learning_user         = false,
){
  include docker

  file { '/etc/docker/ssl_dir/':
    ensure  => directory,
    require => Class['docker'],
  }

  file { '/usr/local/bin/run_agents':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/dockeragent/run_agents',
  }

  if $create_no_agent_image {
    dockeragent::image { 'no_agent':
      install_agent     => false,
      registry          => $registry,
      yum_server        => $yum_server,
      lvm_bashrc        => $lvm_bashrc,
      install_dev_tools => $install_dev_tools,
      learning_user     => $learning_user,
    }
  }

  if $create_agent_image {
    dockeragent::image { 'agent':
      install_agent     => true,
      registry          => $registry,
      yum_server        => $yum_server,
      yum_cache         => $yum_cache,
      lvm_bashrc        => $lvm_bashrc,
      learning_user     => $learning_user,
    }
  } 

}
