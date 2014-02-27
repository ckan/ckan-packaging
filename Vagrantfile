# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64-current"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
  config.ssh.forward_agent = true

  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
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
