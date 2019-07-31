Facter.add(:docker_hosts) do
  setcode do
    containers = Facter::Util::Resolution.exec('docker ps')
    next unless containers

    hosts = {}
    containers = containers.split("\n")
    containers.shift
    containers.each do |line|
      name = line.split.last
      hosts[name] = Facter::Util::Resolution.exec("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' #{name}")
    end

    hosts
  end
end
