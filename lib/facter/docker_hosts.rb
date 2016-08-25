Facter.add(:docker_hosts) do
  setcode do
    if system("docker -v")
      containers = `docker ps | awk '{if(NR>1) print $NF}'`.split
      return containers.inject({}){ |memo, container| memo[container] = `/bin/docker inspect -f '{{ .NetworkSettings.IPAddress }}' #{container}`.chomp; memo }
    else
      return {}
    end
  end
end
