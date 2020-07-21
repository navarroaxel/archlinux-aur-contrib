#!/bin/bash -eu

# Get the build number from the package verion
#
# $1 - Package version
#
# Examples
#   getPackageBuild 2020.2.202.6109.24
#
# Returns the build number from the package version
getPackageBuild() {
  echo "$1" | sed 's/\./\n/g' | tail -3 | tr '\n' '.' | sed 's/\.$/\n/'
}

# Removes the build number from the package version
#
# $1 - Package version
#
# Examples
#   removePackageBuild 2020.1.3b201.8538.32
#
# Returns the product version without the build number
removePackageBuild() {
  echo "$1" | sed 's/b/\n/g' | head -1
}

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
  xmllint --xpath "string(//product[@name='$2']/channel[@id='$3']/build/@$4)" - | \
  head -1
}

PACKAGES=(datagrip goland intellij-idea-ce intellij-idea-ultimate-edition phpstorm pycharm-professional rider rubymine webstorm goland-eap intellij-idea-ce-eap intellij-idea-ue-eap phpstorm-eap pycharm-community-eap rubymine-eap webstorm-eap)
PRODUCTS=(DataGrip GoLand "IntelliJ IDEA" "IntelliJ IDEA" PhpStorm PyCharm Rider RubyMine WebStorm GoLand "IntelliJ IDEA" "IntelliJ IDEA" PhpStorm PyCharm RubyMine WebStorm)
CHANNELS=(
  DB-RELEASE-licensing-RELEASE
  GO-RELEASE-licensing-RELEASE
  IC-IU-RELEASE-licensing-RELEASE
  IC-IU-RELEASE-licensing-RELEASE
  PS-RELEASE-licensing-RELEASE
  PC-PY-RELEASE-licensing-RELEASE
  RD-RELEASE-licensing-RELEASE
  RM-RELEASE-licensing-RELEASE
  WS-RELEASE-licensing-RELEASE
  GO-EAP-licensing-EAP
  IC-IU-EAP-licensing-EAP
  IC-IU-EAP-licensing-EAP
  PS-EAP-licensing-EAP
  PC-PY-EAP-licensing-EAP
  RM-EAP-licensing-EAP
  WS-EAP-licensing-EAP
)

# shellcheck disable=SC2068
AUR=$(fetchAurPackages ${PACKAGES[@]})
UPDATES=$(curl --silent https://www.jetbrains.com/updates/updates.xml)

for (( i = 0; i < ${#PACKAGES[@]}; ++i )); do
  PACKAGE_VERSION=$(getPackageVersion "$AUR" "${PACKAGES[$i]}" | removeEpoch)
  if [[ $i -lt 9 ]];
  then
    VERSION_TYPE="version"
    PACKAGE_VERSION=$(removePackageBuild "$PACKAGE_VERSION")
  else
    VERSION_TYPE="fullNumber"
    PACKAGE_VERSION=$(getPackageBuild "$PACKAGE_VERSION")
  fi
  LATEST_VERSION=$(getUpstreamVersion "$UPDATES" "${PRODUCTS[$i]}" "${CHANNELS[$i]}" "$VERSION_TYPE")
  printUpdate "${PACKAGES[$i]}" "$PACKAGE_VERSION" "$LATEST_VERSION"
done
