require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe 'docker_hosts' do
    context 'returns docker hosts' do
      it do
          docker_hosts_output = <<-EOS
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                      NAMES
0f817077e668        39cb283a805f        "nginx -g 'daemon off"   3 weeks ago         Up 2 weeks          0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx_1
          EOS
        Facter::Util::Resolution.expects(:which).with('docker').returns('/usr/bin/docker')
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:exec).with('docker ps').returns(docker_hosts_output)
        Facter::Util::Resolution.expects(:exec).with("docker inspect -f '{{ .NetworkSettings.IPAddress }}' nginx_1").returns('172.17.0.3')
        expect(Facter.value(:docker_hosts)).to eq({
          "nginx_1" => "172.17.0.3",
        })
      end
    end

    context 'returns nil when docker not present' do
      it do
        Facter::Util::Resolution.expects(:which).at_least(1).with("docker").returns(false)
        expect(Facter.value(:docker_hosts)).to be_nil
      end
    end
  end
end
