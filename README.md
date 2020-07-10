# archlinux-aur-updates

![Lint Code Base](https://github.com/navarroaxel/archlinux-aur-contrib/workflows/Lint%20Code%20Base/badge.svg)

This repository is an integral example in how to automate the release process
for packages in the AUR repository.

## Prerequisites

The scripts in this repository use the command `xmllint` provided by the
`libxml2` package to parse the response from Google Chrome and Jetbrains to
that brings metadata for last updates to different products and channels for
Chrome and Jetbrains.

To parse the response from the aurweb RPC interface I used the `jq` command
provided by the package with the same name. More info about this interface,
see <https://wiki.archlinux.org/index.php/Aurweb_RPC_interface>.

To update the checksums of the `PKGBUILD` automatically, the script uses
the `updpkgsums` command provided by `pacman-contrib` package.

## Source code

The `src` folder has 2 executables bash scripts:

1. The `updates.sh` checks for updates for the google-chrome family packages
in the AUR repository and several products from the stable and EAP channels
of Jetbrains products, like IntelliJ IDEA, PyCharm and others.

2. The `upgpkgver.sh` should be run in the AUR package working directory,
this script will ask for the new version and updates the PKGBUILD file
and compile the new version of the given AUR package.

### Check updates from upstream

To check updates from the upstream using `updates.sh`, these are the common
steps:

1. Fetch the metadata from a source available by the author of the package.
2. Fetch the current version in the AUR repository.
3. Compare the versions, if match display nothing, otherwise display a
simple line similar to the `checkupdates` command:
`<package> <current_ver> -> <new_version>`.

### Upgrade package version

To upgrade the version of an AUR package copy the `upgpkgver.sh` to the
AUR package working directory in your file system.

1. Execute the script.
2. It asks for the new `pkgver` value.
3. The `pkgrel` is set to 1.
3. If the _`pkgver` is defined, it asks if should be updated.
4. It displays the `PKGBUILD` diff, if that's right press `y`, otherwise
the script rollback the changes and exits.
5. Upgrades the checksums using the `updpkgsums` command.
6. Make a clean build using `makepkg` command
7. Update the .SRCINFO file using `makepkg --printsrcinfo` command.

## Examples

The `examples` folder has 2 examples showing how to upgrade the `git-delta-bin`
and `rubymine-eap` packages. You can use this as a guide to build your own
auto updater script for your AUR packages.

### git-delta-bin

To check updates for the `git-delta-bin` package just run the
`git-delta-bin.sh` file, only shows output if an update is available.
This uses the GitHub API to find updates in the stream repository.

To run the auto update PKGBUILD process you should use the following
command, passing the route to the AUR package working directory in your
file system:

```bash
./upg-git-delta-bin.sh ../../git-delta-bin
```

This scripts compares the upstream latest version with the AUR repository
directly using the aurweb RPC interface. If there is a new version use the
process defined in the `src/upgpkgver.sh` to start the update process.

### rubymine-eap

This example makes the same steps and use the same bash functions that the
`git-delta-bin` example but uses the `updates.xml` file, provided by
JetBrains, to find updates in the upstream source.

To run the auto update PKGBUILD process you should use the following
command:

```bash
./upg-rubymine-eap.sh ../../rubymine-eap
```
