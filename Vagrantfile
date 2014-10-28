# -*- mode: ruby -*-
# vi: set ft=ruby :

#load the variables.
# VagrantFile
vagrant_root = File.dirname(__FILE__)
require 'yaml'
vconfig = YAML::load_file("#{vagrant_root}/vagrant_config.yml")

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|  
  
  #UPDATE THIS - Hostname
  config.vm.hostname = vconfig['hostname']
  
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "notgary/ubuntu-14-04-base"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 80
  
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network :private_network, ip: vconfig['ip']

  
  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  #config.vm.synced_folder "/Volumes/Tortoise/Users/maestrojed/Dropbox/Jed/Projects/gitflow/site/http", "/vagrant_data"
  
  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true
  
  #PROVISIONING
  config.vm.provision "shell" do |s|
    s.path = "bootstrap.sh"
    s.args   = "#{vconfig['hostname']} #{vconfig['ip']} #{vconfig['dbHost']} #{vconfig['dbName']} #{vconfig['dbUser']} #{vconfig['dbPass']} #{vconfig['dbRootPass']}"
  end

end
