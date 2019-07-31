# Create and run a Docker containerized Puppet Agent
define dockeragent::node (
  $ensure = present,
  $ports = undef,
  $privileged = false,
  $image = 'agent',
  $require_dockeragent = true,
  $ip_base = '172.18.0',
) {

  if $require_dockeragent {
    require dockeragent
    $gateway_ip = $dockeragent::gateway_ip
  } else {
    $gateway_ip = "${ip_base}.1"
  }

  $container_volumes = [
    '/var/yum:/var/yum',
    '/var/cache/yum:/var/cache/yum',
    '/etc/yum.repos.d:/etc/yum.repos.d',
    '/opt/puppetlabs/server/data:/opt/puppetlabs/server/data',
    '/sys/fs/cgroup:/sys/fs/cgroup:ro',
    '/etc/docker/ssl_dir/:/etc/puppetlabs/puppet/ssl',
    '/var/cache/rubygems:/var/cache/rubygems',
  ]

  docker::run { $title:
    ensure                => $ensure,
    hostname              => $title,
    image                 => $image,
    net                   => 'dockeragent-net',
    command               => '/usr/lib/systemd/systemd',
    ports                 => $ports,
    privileged            => $privileged,
    volumes               => $container_volumes,
    env                   =>  [
      'RUNLEVEL=3',
      'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin',
      'HOME=/root/',
      'TERM=xterm'
    ],
    extra_parameters      => [
      "--add-host \"${::fqdn} puppet:${gateway_ip}\"",
      '--security-opt seccomp=unconfined',
      '--restart=always',
      '--tmpfs /tmp',
      '--tmpfs /run',
    ],
    health_check_cmd      => '/bin/true',
    health_check_interval => 600,
  }

}
