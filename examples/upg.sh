#!/usr/bin/env bash
set -e

# Execute this script to upgrade the AUR package locally
#
# $1 - Name of the command who invokes this script
# $2 - Path to the package directory in file system
#
# Examples
#   ./upg.sh "upg-git-delta-bin.sh" "../git-delta-bin"
#
# Required global variables:
# PACKAGE - Package name in AUR repository
# PACKAGE_VERSION - Current package version in AUR repository
# LATEST_VERSION - Latest version from upstream

if [[ $PACKAGE_VERSION == "$LATEST_VERSION" ]]; then
  echo "$PACKAGE is up to date.";
  exit 0;
fi

if [[ ! $2 ]] ; then
  echo -e "\e[0;31mPackage directory not specified.\033[00m"
  echo "Usage: $1 <directory>"
  exit 1;
fi

printUpdate "$PACKAGE" "$PACKAGE_VERSION" "$LATEST_VERSION"

# Save current directory path in a variable
DIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"

# Change working directory to package directory
cd "$2" && git pull || exit 1;

. "$DIR/../src/upgpkgver.sh" "$LATEST_VERSION"
