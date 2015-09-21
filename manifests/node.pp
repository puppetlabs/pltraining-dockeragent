# Create and run a Docker containerized Puppet Agent
define dockeragent::node (
  $ports = undef,
) {
  require dockeragent

  if $::ipaddress_docker0 {
    docker::run { $title:
      hostname         => $title,
      image            => 'agent',
      command          => '/sbin/init 3',
      use_name         => true,
      privileged       => true,
      ports            => $ports,
      volumes          => $dockeragent::container_volumes,
      extra_parameters => [
        "--add-host \"${::fqdn} puppet:${::ipaddress_docker0}\"",
        '--restart=always',
      ],
    }

  } else {
    notify { 'Docker has not yet been configured on this node.': }
  }
}
