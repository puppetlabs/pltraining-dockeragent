# Create and run a Docker containerized Puppet Agent
define dockeragent::node (
  $ports = undef,
  $remove_container_on_start = true,
  $remove_container_on_stop = true
) {
  require dockeragent

  docker::run { $title:
    hostname                  => $title,
    image                     => 'agent',
    command                   => '/usr/lib/systemd/systemd',
    ports                     => $ports,
    volumes                   => $dockeragent::container_volumes,
    remove_container_on_start => $remove_container_on_start,
    remove_container_on_stop  => $remove_container_on_stop,
    extra_parameters => [
      "--add-host \"${::fqdn} puppet:${::ipaddress_docker0}\"",
      '--restart=always',
    ],
  }
}
