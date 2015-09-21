class dockeragent::sample::wordpress {
    class { 'mysql::server':
        root_password => 'puppetlabs',
    }
    class { 'mysql::bindings':
        php_enable => true,
    }
    
    include apache
    include apache::mod::php
    apache::vhost { $::fqdn:
        port     => '80',
        priority => '00',
        docroot  => '/opt/wordpress',
    }
    
    include ::wordpress
}
