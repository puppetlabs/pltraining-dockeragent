# Set up docker images

class dockeragent (
  $create_agent_image    = true,
  $create_no_agent_image = true,
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
      install_agent => false,
    }
  }

  if $create_no_agent_image {
  dockeragent::image { 'agent':
    install_agent => true,
  } 

}
