#!/usr/bin/env bash
set -e

# Execute this script to upgrade the AUR package locally
#
# $1 - [Optional] New pkgver value

# Checks if the variable is defined in the PKGBUILD file
#
# $1 - Variable name
#
# Examples
#   hasVariable _pkgver
#
# Returns 1 if the variable is defined else returns 0
hasVariable() {
  grep -c "^$1=" PKGBUILD
}

# Get the line of the variable in the PKGBUILD file
#
# $1 - Variable name
#
# Examples
#   getVariable pkgver
#
# Returns the variable line in the PKGBUILD file
getVariable() {
  grep "^$1=" PKGBUILD
}

# Set the value of a variable in PKGBUILD file
#
# $1 - Variable name
# $2 - Variable value
#
# Examples
#   setVariable pkgver 1.10
setVariable() {
  local CURRENT_VALUE
  CURRENT_VALUE=$(getVariable "$1") && sed -i "s/$CURRENT_VALUE/$1=$2/" PKGBUILD
}

# Build the package in the current directory
buildPackage() {
  makepkg --syncdeps --cleanbuild && rm -rf pkg/ src/
}

# Update the source info file in the current directory
#
# Update the .SRCINFO file for the current directory
# https://wiki.archlinux.org/index.php/.SRCINFO
updateSourceInfo() {
  touch .SRCINFO && rm .SRCINFO && makepkg --printsrcinfo > .SRCINFO
}

if [[ ! $1 ]] ; then
  # Ask for new pkgver in an interactive session
  getVariable pkgver
  read -p "New pkgver=" -r NEW_VERSION
else
  NEW_VERSION=$1
fi

if [[ ! $NEW_VERSION ]] ; then
  exit 0;
fi

setVariable pkgrel 1
cp PKGBUILD .PKGBUILD.bak && setVariable pkgver "$NEW_VERSION"

# Checks if exists _pkgver
if [[ $(hasVariable _pkgver) -eq 1 ]] ; then
  # Ask to update _pkgver or keep current value
  CURRENT_VERSION=$(getVariable _pkgver)
  read -p "($CURRENT_VERSION) _pkgver=" -r NEW_VERSION

  # check if keep current _pkgver value
  if [[ $NEW_VERSION ]] ; then
    setVariable _pkgver "$NEW_VERSION"
  fi
fi

git diff -- PKGBUILD
read -p "Do you want to continue? [y/n]" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
  mv .PKGBUILD.bak PKGBUILD
  # shellcheck disable=SC2128
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

rm .PKGBUILD.bak \
  && updpkgsums \
  && buildPackage \
  && updateSourceInfo
