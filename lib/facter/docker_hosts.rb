Facter.add(:docker_hosts) do
  setcode do
    containers = `docker ps | awk '{if(NR>1) print $NF}'`.split
    containers.inject({}){ |memo, container| memo[container] = `/bin/docker inspect -f '{{ .NetworkSettings.IPAddress }}' #{container}`.chomp; memo }
  end
end
