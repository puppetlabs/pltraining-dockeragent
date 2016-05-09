# Create and run a Docker containerized Puppet Agent
define dockeragent::node (
  $ports = undef,
  $image = 'agent',
) {
  require dockeragent

  docker::run { $title:
    hostname         => $title,
    image            => $image,
    command          => '/usr/lib/systemd/systemd',
    ports            => $ports,
    volumes          => $dockeragent::container_volumes,
    extra_parameters => [
      "--add-host \"${::fqdn} puppet:${::ipaddress_docker0}\"",
      '--restart=always',
    ],
  }
}
