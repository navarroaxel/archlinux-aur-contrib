#!/bin/bash -eu

# Fetch the metadata of the given packages by name
#
# Uses the aurweb RPC interface to fetch metadata of a list of packages with the multiinfo response,
#   https://wiki.archlinux.org/index.php/Aurweb_RPC_interface#info_2
#
# $@ - Space separated package names
#
# Examples
#   fetchAurPackages google-chrome google-chrome-beta
#
# Returns the JSON response from the aurweb RPC interface.
fetchAurPackages() {
  local ARGS
  # shellcheck disable=SC2068
  ARGS=$(printf "&arg[]=%s" $@)
  curl --silent "https://aur.archlinux.org/rpc/?v=5&type=info$ARGS"
}

# Removes the pkgrel number from the package version
#
# stdin - Package version
#
# Examples
#   echo "1.10-1" | removeReleaseNumber
#
# Returns the package version without the pkgrel value
removeReleaseNumber() {
  sed 's/-/\n/g' | head -1
}

# Removes the epoch number from the package version
#
# stdin - Package version
#
# Examples
#   echo "2:2.1" | removeEpoch
#
# Returns the package version without the epoch value.
removeEpoch() {
  sed 's/:/\n/g' | tail -1
}

# Get the current version of the given package by name
#
# Filters the multiinfo response from the aurweb RPC interface to get the package metadata
#
# $1 - A multiinfo JSON from the aurweb RPC interface
# $2 - Package name
#
# Examples
#   getPackageVersion "{...}" dropbox
#
# Returns the version of the given package without the pkgrel value.
getPackageVersion() {
  echo "$1" | jq -r ".results[] | select(.Name == \"$2\") | .Version" | removeReleaseNumber
}

# Prints the package update if the upstream version does not match the package one.
#
# $1 - Package name
# $2 - Package version in the repository
# $3 - Package version in the upstream repository
#
# Examples
#   printUpdate mongodb 4.1.0 4.1.1
#
# Returns the update message if the versions does not match or nothing otherwise.
printUpdate() {
  if [[ $2 != "$3" ]]; then
    echo "$1 $2 -> $3"
  fi
}
