# This Class sets up the docker environment and image(s)

class dockeragent (
  $registry = undef,
  $yum_server = 'master.puppetlabs.vm',
  $yum_cache = false,
){
  include docker

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
    undef   => 'maci0/systemd',
    default => "${registry}/maci0/systemd",
  }
  $docker_files.each |$docker_file|{
    file { "/etc/docker/agent/${docker_file}":
      ensure         => file,
      content        => epp("dockeragent/${docker_file}.epp",{
        'os_major'   => $::os['release']['major'],
        'yum_server' => $yum_server,
        'basename'   => $image_name,
        'yum_cache'  => $yum_cache,
        }),
    }
  }

  file { "/etc/docker/agent/download_catalogs.sh":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/dockeragent/download_catalogs.sh',
  }

  file { "/etc/docker/agent/refresh-mcollective-metadata":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/dockeragent/refresh-mcollective-metadata',
  }

  file { "/etc/docker/agent/root.cron":
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/dockeragent/root.cron',
  }
  
  file { "/etc/docker/agent/crond.pam":
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/dockeragent/crond.pam',
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
