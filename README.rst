CKAN Packaging Scripts
======================

These scripts are used to build Debian packages (deb files) for CKAN releases.

How it works
------------

We use `Ansible <http://ansible.cc>`_ to automate the creation of the package
in a dedicated build server. This server needs to be running the same
distribution and architecture that we target for CKAN packages (currently
Ubuntu 12.04 64bit).

Ansible needs to be installed in your local machine and it is configured via
`playbooks <http://ansible.cc/docs/playbooks.html>`_. These are a set of
configurations and tasks that are run in the remote server. The file we use
is `package.yml` and it is quite straight-forward to follow what is going on.

The actual packaging is done in the remote server by
`FPM <https://github.com/jordansissel/fpm>`_, a tool that aims to make building
packages quickly and easily.


Install and setup
-----------------

1. You will need sudo SSH access to a bare server running Ubuntu 12.04 64bit.
   For testing and understanding how the packaging works you can use a local
   VM. For instance on VirtualBox:

   * Create a new VM, and on the Network settings select "Bridged Adapter".
   * Install Ubuntu 12.04 64 bit and install `openssh-server`.
   * Test that you can login from your host system to the IP that `ifconfig`
     gives you on the guest system.

   For production, we are currently using `packaging.ckan.org` for building
   the packages. Ask a sysadmin if you can not login.

   The remote server should have a `/var/www/build` directory, as this is were
   the packages will be created. Of course, if you also want to serve the
   packages via HTTP you will need to install Apache or similar.

2. Install ansible on your local machine (either on a virtualenv or globally)::

    pip install ansible

3. Create a hosts file name `/etc/ansible/hosts` with the following entry,
   making sure to replace the IP with your target building server (a local VM
   or `packaging.ckan.org`)::

    [build]
    1.1.1.1

4. Checkout this repository in your virtualenv.


Building a package
------------------

Packages are built running the ansible playbook command. From the directory
where you checked out this repository, run::

    ansible-playbook package.yml

You may have to supply connection parameters to ansible-playbook like
a private-key or password to connect. For instance, to connect as a specific
user and run commands with sudo::

    ansible-playbook package.yml -u amercader -s

See `ansible-playbook --help` for more options.

You will be prompted for the CKAN version you want to build
(ie release-v<Version>) and an iteration number.

You will see the output of the different tasks. The first time you run it it
may take a while, as all the required packages will be installed in the remote
server. Once the process is finished, you should see a summary of the tasks.
All tasks should be `ok` or `changed`.

The packages will be created in `/var/www/build` in the remote server. For
the production server, this can be accessed at the following URL:

http://packaging.ckan.org/build/

**Do not** copy any file to the root directory (`/var/www`) unless you are a
release manager and publishing a new release.
