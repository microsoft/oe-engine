#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Install required packages.
#
# When using new tools, obtain the corresponding package they come from with
# dpkg -S <binary-name>
# and add it to the list.
#
#

source /opt/azure/acc/utils.sh

# validate open-enclave package installation
status=$(dpkg -s open-enclave | grep "Status: install ok installed")
if [ $? -ne 0  ] || [ -z "$status" ]; then
  echo "open-enclave is not installed"
  exit 1
fi

# exit on error from this point
set -e

# copy samples
tempdir="$(mktemp -d)"
trap "rm -rf \"${tempdir}\"" EXIT
cp -r /opt/openenclave/share/openenclave/samples/ $tempdir

# build and run helloworld
cd $tempdir/samples/helloworld
make
make run

echo "open-enclave validation succedded"
