#!/bin/bash -eu

# Fetch the Google Chrome versions for the 3 channels
#
# Fetch the XML from Google with the version for each Chrome release channel:
# stable, beta and unstable.
#
# Examples
#   fetchUpdates
#
# Returns the XML with the available versions of Google Chrome.
fetchUpdates() {
  curl --silent --location \
  https://dl.google.com/linux/chrome/rpm/stable/x86_64/repodata/other.xml.gz | \
  gzip --decompress
}

# Get the latest version for the given Chrome channel release
#
# Finds the given Chrome release channel in the XML metadata for Yum and returns the version.
#
# $1 - A XML with metadata for Yum
# $2 - Channel name: google-chrome-stable, google-chrome-beta or google-chrome-unstable
#
# Examples
#   getLatestVersion "<?xml ..." google-chrome-stable
#
# Returns the version for the given Google Chrome channel
getLatestVersion() {
  echo "$1" | \
  xmllint --xpath "//*[local-name()='package'][@name='$2']" - | \
  xmllint --xpath "string(//version/@ver)" -
}

PACKAGES=(google-chrome google-chrome-beta google-chrome-dev)
PRODUCTS=(google-chrome-stable google-chrome-beta google-chrome-unstable)
# shellcheck disable=SC2068
AUR=$(fetchAurPackages ${PACKAGES[@]})
UPDATES=$(fetchUpdates)

for (( i = 0; i < ${#PACKAGES[@]}; ++i )); do
  PACKAGE_VERSION=$(getPackageVersion "$AUR" "${PACKAGES[$i]}")
  LATEST_VERSION=$(getLatestVersion "$UPDATES" "${PRODUCTS[$i]}")
  printUpdate "${PACKAGES[$i]}" "$PACKAGE_VERSION" "$LATEST_VERSION"
done
