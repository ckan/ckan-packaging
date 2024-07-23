# CKAN Packaging Scripts

These scripts are used to build Debian packages (deb files) for CKAN releases.

> [!NOTE] As of July 2024, Docker is used as a building environment to create the deb packages.
> The previous Ansible / Vagrant setup is no longer used

## Overview

To create Debian packages of CKAN, install Docker and run:

```
docker buildx build \
	--output type=local,dest=.  \
	--build-arg CKAN_VERSION=2.11 \
	--build-arg CKAN_BRANCH=dev-v2.11 \
	--build-arg DATAPUSHER_VERSION=0.0.21 \
	--build-arg DISTRIBUTION=noble \
	--build-arg UBUNTU_VERSION=24.04 \
	.
```

The currently supported packages are:

| CKAN version | Ubuntu version |
| ------------ | -------------- |
| 2.10         | 20.04 (focal)  |
| 2.10         | 22.04 (jammy)  |
| 2.11         | 22.04 (jammy)  |
| 2.11         | 24.04 (noble)  |

Any other combination is not officially supported, although you might be able to
build it tweaking the parameters above.



TODO
