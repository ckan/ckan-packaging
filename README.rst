CKAN Packaging Scripts
======================

These scripts are used to build Debian packages (deb files) for CKAN releases.

Overview
--------

To create Debian packages of CKAN, install Vagrant and Ansible and run::

    ./ckan-package -v dev-v2.8 -i 1

If you omit the parameters you will be prompted for them.

After Vagrant and Ansible have done their thing (it will take a while), you
should end up with three deb files on the working folder::

    python-ckan_dev-v2.8-trusty1_amd64.deb
    python-ckan_dev-v2.8-xenial1_amd64.deb
    python-ckan_dev-v2.8-bionic1_amd64.deb

Keep reading for more options and to learn how it works.


How it works
------------

This repository contains a `Vagrant <https://www.vagrantup.com/>`_ environment
configured in a `multi-machine <https://docs.vagrantup.com/v2/multi-machine>`_ setup.

Each machine is running one of the supported distributions that we target, currently:

* Ubuntu 14.04 64bit (trusty)
* Ubuntu 16.04 64bit (xenial)
* Ubuntu 18.04 64bit (bionic)

We use `Ansible <http://ansible.com>`_ to provision the Vagrant machines, which
results in the creation of the package. Ansible is configured via
`playbooks <http://docs.ansible.com/ansible/playbooks.html>`_. These are a set of
configurations and tasks that are run in the remote server. The file we use
is `package.yml` and it is quite straight-forward to follow what is going on.

The actual packaging is done in the building maching by
`FPM <https://github.com/jordansissel/fpm>`_, a tool that aims to make building
packages quickly and easily.

To pass parameters like the CKAN version or the iteration to the Vagrant file and
ultimately to Ansible we need to use env vars. To make this a little bit more
convenient, the ``ckan-package`` script is included, which essentially sets up the
necessary env vars and calls ``vagrant up`` or ``vagrant provision`` as appropiate.


Install and setup
-----------------

1. Install Vagrant. On an Ubuntu machine::

    sudo apt-get install vagrant

   Or for an OSX machine use the installer at https://www.vagrantup.com/downloads.html

2. Install Ansible. If you have a virtualenv you can install it in that::

    pip install ansible

   Otherwise simply install it globally::

    sudo easy_install ansible

3. Checkout this repository in your virtualenv or elsewhere::

    git clone https://github.com/ckan/ckan-packaging.git
    cd ckan-packaging

You are now ready to build packages.


Building a package
------------------

Packages are built using the ``ckan-package`` script. Check the following for a
full list of options and parameters::

    ./ckan-package --help

Most of the times you will want to run something like the following::

    ./ckan-package -v dev-v2.8 -i 1

Where:

 * -v (version) relates to the CKAN  branch or tag to build, eg master, dev-v2.6, release-v2.5.3
 * -i (iteration) e.g. `beta1` for a beta or for a proper release use a number e.g. `1`

This will build two packages successively, one for trusty and one for xenial. If you
only want to target one distribution, you can pass the ``-t`` parameter::

    ./ckan-package --version dev-v2.8 --iteration 1 --target bionic

The first time that you run the build commands Vagrant will
need to download the OS images from the central repository, this might take a while.
After the first run, the image will be already on your machine so it won't take as much.
Most of the steps in the Ansible playbook (like installing required packages) will be also
skipped, so subsequent builds should be much faster.

You will see the output of the different tasks, both for Vagrant and Ansible.
Once the process is finished, you should see a summary of the tasks.
All tasks should be `ok` or `changed`.

The packages will be created in the same directory.

TODO: upload the packages to S3 (http://packaging.ckan.org/build/).
