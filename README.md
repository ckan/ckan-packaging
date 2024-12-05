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

# Release process

There are two separate workflows:

* One builds the deb packages (based on the versions supplied in `VERSIONS.json`) and stores them as artifacfts in the workflow run page. This is triggered on every push.


* Additionally, when a tag is pushed, another workflow also builds the packages and:
   1. Uploads them to the S3 bucket powering https://packaging.ckan.org
   2. Creates a new GitHub release with the packages attached as assets.

With this, the suggested release process is the following:

* Whenever there is a new CKAN release in the works, or fixes need to be applied to the packages, a new branch and pull request is created. This will trigger the workflows that will create the packages for that version of the code. The `ckan_ref` should be the relvant development branch (e.g. `dev-v2.11`).
* The packages can be downloded from the workflow page to test locally. Once everthing looks fine the PR is merged.
* A new tag in the form `vYYYYMMDD` is pushed to trigger the publication of the packages and the creation of the release.
