CKAN Packaging Scripts
======================

These scripts are used to build Debian packages (deb files) for CKAN releases.

Overview
--------

Install Vagrant and Ansible and run::

    ./ckan-package -v 2.4.2 -i 1

If you omit the parameters you will be prompt for them.

After Vagrant and Ansible have done their thing (it will take a while), you
should end up with two deb files on the working folder::

    python-ckan_2.4.2-precise1_amd64.deb
    python-ckan_2.4.2-trusty1_amd64.deb


Keep reading for more options and to learn how it works.


How it works
------------

This repository contains a `Vagrant <https://www.vagrantup.com/>`_ environment
configured in a `multi-machine <https://docs.vagrantup.com/v2/multi-machine>`_ setup.

Each machine is running one of the supported distributions that we target, currently:

* Ubuntu 12.04 64bit (precise)
* Ubuntu 14.04 64bit (trusty)

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

1. Install Vagrant::

    sudo apt-get install vagrant

  Or for more recent versions, head to http://www.vagrantup.com/downloads


2. Install Ansible (either on a virtualenv or globally)::

    pip install ansible

3. Checkout this repository in your virtualenv.

You are now ready to go.

Building a package
------------------

Packages are built using the ``ckan-package`` script. Check the following for a
full list of options and parameters::

    ./ckan-package --help

Most of the times you will want to run something like the following::

    ./ckan-package -v 2.4.2 -i 1

or::

    ./ckan-package --version 2.4.2 --iteration 1

This will build two packages successively, one for precise and one for trusty. If you
only want to target one distribution, you can pass the ``-t`` parameter::

    ./ckan-package --version 2.4.2 --iteration 1 --target trusty

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
