#!/usr/bin/env bash
set -e
source ../src/common.sh

# Get the upstream version from the Jetbrains XML
#
# Finds the Jetbrains product and returns the current version for the given release channel.
#
# $1 - A XML with the Jetbrains products metadata
# $2 - Product name
# $3 - Release channel
# $4 - Version type: version, number, fullNumber (includes patch version).
#
# Examples
#   getUpstreamVersion "<product ..." "IntelliJ IDEA" IC-IU-RELEASE-licensing-RELEASE version
#   getUpstreamVersion "<product ..." "IntelliJ IDEA" IC-IU-EAP-licensing-EAP fullNumber
#
# Returns the product version for the given channel release or nothing otherwise.
getUpstreamVersion() {
  echo "$1" | \
  xmllint --xpath "string(//product[@name='$2']/channel[1]/build/@$4)" - | \
  head -1
}

PACKAGE=rubymine-eap
AUR=$(fetchAurPackages $PACKAGE)
UPDATES=$(curl --silent https://www.jetbrains.com/updates/updates.xml)

PACKAGE_VERSION=$(getPackageVersion "$AUR" "$PACKAGE")
LATEST_VERSION=$(getUpstreamVersion "$UPDATES" RubyMine RM-EAP-licensing-EAP fullNumber)

# Public: Current package version in AUR repository
export PACKAGE_VERSION
# Public: Latest version from the upstream repository
export LATEST_VERSION
