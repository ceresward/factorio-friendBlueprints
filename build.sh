#!/bin/bash

# Take version from the command-line if provided, otherwise prompt for it
if [ -z "$1" ]
then
  read -p "Version: " version
else
  version="$1"
fi


appdata_fixed=$(echo $APPDATA | tr '\\' '/')

mod_name="FriendBlueprints"
build_dir="zip"

set -x
cp -r src ${build_dir}/${mod_name}_${version}