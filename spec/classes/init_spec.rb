require 'spec_helper'

describe "dockeragent" do
  let(:node) { 'test.example.com' }

  let(:facts) { {
    :os                        => {
      :family                  => 'RedHat',
      :release => {
        :major => '7',
        :minor => '2',
      }
    },
    :osfamily                  => 'RedHat',
    :operatingsystem           => 'CentOS',
    :operatingsystemrelease    => '7.2.1511',
    :operatingsystemmajrelease => '7',
    :kernel                    => 'Linux',
    :kernelversion             => '3.10.0',
  } }

  let(:pre_condition) do
    <<-EOF
    EOF
  end

  it { is_expected.to compile.with_all_deps }
end
