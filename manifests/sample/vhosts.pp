class dockeragent::sample::vhosts {
    # create 25 testing vhosts
    range(0,25).each |$n| {
        $name = "user${n}"
        apache::vhost { "${name}.example.com":
            port          => '80',
            docroot       => "/home/${name}/public_html",
            docroot_owner => $name,
        }
    
        file { "/home/${name}":
            ensure => directory,
            owner  => $name,
            group  => $name,
        }
    
        user { $name:
            ensure => present,
        }
    }
}
