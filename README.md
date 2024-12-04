# CKAN Packaging Scripts

These scripts are used to build Debian packages (deb files) for CKAN releases.

> [!WARNING] These scripts are used by CKAN maintainers. If you want to install CKAN, including
> via Debian package, check the [installation documentation](https://docs.ckan.org/en/latest/maintaining/installing/index.html)

> [!NOTE] As of December 2024, Docker is used as a building environment to create the deb packages.
> The previous Ansible / Vagrant setup is no longer used

## Overview

To create Debian packages of CKAN, use the `ckan-package` executable:

```
/ckan-package --help
usage: ckan-package [-h] [-i ITERATION] ref target

Builds CKAN deb packages. This script essentially sets up the necessary vars and calls `docker buildx build`.

positional arguments:
  ref                   The CKAN branch or tag to build (e.g. master, dev-v2.11, ckan-2.10.6...)
  target                The Ubuntu version to target (e.g. 20.04, 22.04, 24.04...)

optional arguments:
  -h, --help            show this help message and exit
  -i ITERATION, --iteration ITERATION
                        The iteration number to add to the package name.
```

For instance:

	./ckan-package ckan-2.11.1 24.04
	./ckan-package dev-v2.11 22.04
	./ckan-package master 24.04

The currently supported packages are:

| CKAN version | Ubuntu version |
| ------------ | -------------- |
| 2.10         | 20.04 (focal)  |
| 2.10         | 22.04 (jammy)  |
| 2.11         | 22.04 (jammy)  |
| 2.11         | 24.04 (noble)  |

Any other combination is not officially supported, although you might be able to
build it tweaking the parameters above.

# How it works

Under the hood, the `ckan-package` command just calls `docker buildx build`. You can
call it directly using the appropiate build arguments:

```
docker buildx build \
	--output type=local,dest=.  \
	--build-arg CKAN_REF=ckan-2.11.0 \
	--build-arg UBUNTU_VERSION=24.04 \
	.
```
