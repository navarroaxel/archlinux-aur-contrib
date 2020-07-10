#!/usr/bin/env bash
set -e

# Execute this script with the package directory as parameter
# Examples
#   ./upg-rubymine-eap.sh "../rubymine-eap"

source ./rubymine-eap-common.sh
. upg.sh "upg-rubymine-eap.sh" "$1"
