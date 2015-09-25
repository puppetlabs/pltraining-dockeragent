# This Class sets up the docker environment and image(s)

class dockeragent (
  $registry = undef,
  $yum_server = 'master.puppetlabs.vm',
){
  include docker

  $yum_server_ip = getaddress($yum_server)

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

  file { ['/etc/docker/agent/','/etc/docker/ssl_dir/']:
    ensure  => directory,
    require => Class['docker'],
  }

  $docker_files = [
    "Dockerfile",
    "base_cache.repo",
    "epel_cache.repo",
    "puppet.conf",
    "updates_cache.repo",
    "yum.conf",
  ]
  $image_name = $registry ? {
    undef   => 'centos',
    default => "${registry}/centos",
  }
  $docker_files.each |$docker_file|{
    file { "/etc/docker/agent/${docker_file}":
      ensure        => file,
      content       => epp("dockeragent/${docker_file}.epp",{
        'os_major'  => $::os['release']['major'],
        'yum_server' => $yum_server_ip,
        'basename'  => $image_name,
        }),
    }
  }

  file { "/etc/docker/agent/download_catalogs.sh":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/dockeragent/download_catalogs.sh',
  }

  file { '/usr/local/bin/run_agents':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/dockeragent/run_agents',
  }

  docker::image {'agent':
    docker_dir => '/etc/docker/agent/',
    require    => File['/etc/docker/agent/'],
  }
}
