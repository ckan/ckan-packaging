# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "focal" do |focal|
    focal.vm.box = "ubuntu/focal64"
  end

  config.vm.define "jammy" do |focal|
    focal.vm.box = "ubuntu/jammy64"
  end

  config.vm.define "noble" do |focal|
    focal.vm.box = "ubuntu/noble64"
  end

  config.ssh.forward_agent = true
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    v.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
 
  end

  config.vm.provision "ansible" do |ansible|
     ansible.playbook = "package.yml"
     ansible.host_key_checking = false
     ansible.become = true
     ansible.compatibility_mode = "2.0"

     ansible.verbose = ENV.fetch("CKAN_PACKAGE_ANSIBLE_VERBOSE", "vv")
     ansible.extra_vars = {}

     ansible.extra_vars["datapusher"] = ENV.fetch("CKAN_PACKAGE_DATAPUSHER", "y")

     if ENV.has_key?("CKAN_PACKAGE_VERSION")
         ansible.extra_vars["version"] = ENV["CKAN_PACKAGE_VERSION"]
     end
     if ENV.has_key?("PYTHON_VERSION")
         ansible.extra_vars["pythonversion"] = ENV["PYTHON_VERSION"]
     end
     if ENV.has_key?("CKAN_PACKAGE_ITERATION")
         ansible.extra_vars["iteration"] = ENV["CKAN_PACKAGE_ITERATION"]
     end
   end
end
