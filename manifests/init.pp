# Set up docker images

class dockeragent (
  $registry              = undef,
  $yum_cache             = false,
  $lvm_bashrc            = false,
  $install_dev_tools     = false,
  $learning_user         = false,
  $ip_base               = '172.18.0',
  $image_name            = 'agent',
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

  dockeragent::image { 'no_agent':
     install_agent     => false,
     registry          => $registry,
     yum_cache         => $yum_cache,
     lvm_bashrc        => $lvm_bashrc,
     install_dev_tools => $install_dev_tools,
     learning_user     => $learning_user,
     gateway_ip        => $gateway_ip,
   }

   dockeragent::image { $image_name:
     install_agent     => true,
     image_name        => 'no_agent',
     registry          => $registry,
     yum_cache         => $yum_cache,
     lvm_bashrc        => $lvm_bashrc,
     install_dev_tools => $install_dev_tools,
     learning_user     => $learning_user,
     gateway_ip        => $gateway_ip,
     require           => Dockeragent::Image['no_agent'],
   }

}
