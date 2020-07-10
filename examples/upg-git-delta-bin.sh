#!/usr/bin/env bash
set -e

# Execute this script with the package directory as parameter
# Examples
#   ./upg-git-delta-bin.sh "../git-delta-bin"

source ./git-delta-common.sh
. upg.sh "upg-git-delta-bin.sh" "$1"
