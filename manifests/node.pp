# Create and run a Docker containerized Puppet Agent
define dockeragent::node (
  $ensure = present,
  $ports = undef,
  $image = 'agent',
) {
  require dockeragent

  $container_volumes =  $::os['release']['major'] ? {
    '6' => [
      '/var/yum:/var/yum',
      '/etc/docker/ssl_dir/:/etc/puppetlabs/puppet/ssl',
    ],
    '7' => [
      '/var/yum:/var/yum',
      '/sys/fs/cgroup:/sys/fs/cgroup:ro',
      '/etc/docker/ssl_dir/:/etc/puppetlabs/puppet/ssl',
    ],
  }

  docker::run { $title:
    ensure           => $ensure,
    hostname         => $title,
    image            => $image,
    command          => '/usr/lib/systemd/systemd',
    ports            => $ports,
    volumes          => $container_volumes,
    extra_parameters => [
      "--add-host \"${::fqdn} puppet:${::ipaddress_docker0}\"",
      '--restart=always',
    ],
  }

}
