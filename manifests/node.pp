# Create and run a Docker containerized Puppet Agent
define dockeragent::node (
  $ensure = present,
  $ports = undef,
  $privileged = false,
  $image = 'agent',
) {
  require dockeragent

  $container_volumes = [
    '/var/yum:/var/yum',
    '/sys/fs/cgroup:/sys/fs/cgroup:ro',
    '/etc/docker/ssl_dir/:/etc/puppetlabs/puppet/ssl',
  ]

  docker::run { $title:
    ensure           => $ensure,
    hostname         => $title,
    image            => $image,
    command          => '/usr/lib/systemd/systemd',
    ports            => $ports,
    privileged       => $privileged,
    volumes          => $container_volumes,
    env              =>  [
      'RUNLEVEL=3',
      'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
      'HOME=/root/',
      'TERM=xterm'
    ],
    extra_parameters => [
      "--add-host \"${::fqdn} puppet:${::ipaddress_docker0}\"",
      '--security-opt seccomp=unconfined',
      '--restart=always',
      '--tmpfs /tmp',
      '--tmpfs /run',
    ],
  }

}
