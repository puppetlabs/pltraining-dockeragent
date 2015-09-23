# pltraining/dockeragent

This module is used to configure simple Dockerized agent nodes for the classroom
environment in Puppet Labs training courses. Unless you are an instructor, this
is probably not the module you are looking for. It makes certain assumptions
about the environment and is only flexible within the design specs of our
training courses.

That being said, you're welcome to poke through it and see how we set things up.

## Usage

```Puppet
include dockeragent

# This will manage 5 containerized agents.
range(1,5).each |$n| {
    dockeragent::node { "agent${n}.${::fqdn}":
        ports => ["${n}0080:80"],
    }
}
```

## Example workloads

One thing that containerized agents are sometimes used for is simulating the
load of running an environment against a Puppet master. To facilitate that,
we've included a handful of very simple sample testing profiles. They don't
really do anything useful other than provide the master with a reasonable, if
small, catalog to compile.

```Puppet
node default {
  include dockeragent::sample::wordpress
  include dockeragent::sample::vhosts
}
```

The modules used by these classes are not set as dependencies, so they will not
be installed automatically by `puppet module install`. If you want to use them,
you'll want to install them separately:

* Requirements for `dockeragent::sample::wordpress`:
  * `hunner/wordpress`
  * `puppetlabs/apache`
  * `puppetlabs/mysql`
* Requirements for `dockeragent::sample::vhosts`:
  * `puppetlabs/apache`
  * Future parser or Puppet 4.x

### Other projects:

For another take on the idea of load testing the Puppet master, see
https://github.com/puppetlabs/clamps.

Contact
-------

education@puppetlabs.com
