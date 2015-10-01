# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  #config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/trusty64"
  config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/20150928.0.0/providers/virtualbox.box"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |v|
     v.memory = 1024
  end
  config.vm.provision "ansible" do |ansible|
     ansible.playbook = "package.yml"
     #ansible.inventory_path = "vagranthost"
     ansible.host_key_checking = false
     ansible.verbose = "vvvv"
     ansible.sudo = true
   end
end
