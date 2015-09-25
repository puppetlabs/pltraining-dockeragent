# getaddress.rb
# Looks up a hostname and gets the first ipaddress
 
require 'resolv'
 
module Puppet::Parser::Functions
    newfunction(:getaddress, :type => :rvalue) do |args|
        result = Resolv.new.getaddress(args[0])
        return result
    end
end
