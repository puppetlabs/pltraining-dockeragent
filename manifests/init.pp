# Set up docker images

class dockeragent (
  $create_agent_image    = true,
  $create_no_agent_image = false,
  $registry              = undef,
  $yum_cache             = false,
  $lvm_bashrc            = false,
  $install_dev_tools     = false,
  $learning_user         = false,
  $ip_base               = '172.18.0',
){
  include docker

  $gateway_ip = "${ip_base}.1"
  $subnet     = "${ip_base}.0/16"
  $ip_range   = "${ip_base}.2/24"

  file { '/etc/docker/ssl_dir/':
    ensure  => directory,
    require => Class['docker'],
  }

  file { '/usr/local/bin/run_agents':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/dockeragent/run_agents',
  }

  docker_network { 'dockeragent-net':
    ensure   => present,
    driver   => 'bridge',
    subnet   => $subnet,
    gateway  => $gateway_ip,
    ip_range => $ip_range,
  }

  if $create_no_agent_image {
    dockeragent::image { 'no_agent':
      install_agent     => false,
      registry          => $registry,
      yum_cache         => $yum_cache,
      lvm_bashrc        => $lvm_bashrc,
      install_dev_tools => $install_dev_tools,
      learning_user     => $learning_user,
      gateway_ip        => $gateway_ip,
    }
  }

  if $create_agent_image {
    dockeragent::image { 'agent':
      install_agent     => true,
      registry          => $registry,
      yum_cache         => $yum_cache,
      lvm_bashrc        => $lvm_bashrc,
      install_dev_tools => $install_dev_tools,
      learning_user     => $learning_user,
      gateway_ip        => $gateway_ip,
    }
  } 

}
