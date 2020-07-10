#!/bin/bash -eu
source ../src/common.sh

# Fetch the latest git-delta version from the GitHub API
#
# Uses the GitHub API to fetch the latest tag from the upstream repository
#
# Examples
#   fetchUpdates
#
# Returns the latest version for delta software
fetchLatestVersion() {
  curl --silent https://api.github.com/repos/dandavison/delta/releases/latest | jq -r ".name"
}

PACKAGE=git-delta-bin
AUR=$(fetchAurPackages $PACKAGE)
PACKAGE_VERSION=$(getPackageVersion "$AUR" "$PACKAGE")
LATEST_VERSION=$(fetchLatestVersion)

# Public: Current package version in AUR repository
export PACKAGE_VERSION
# Public: Latest version from the upstream repository
export LATEST_VERSION
