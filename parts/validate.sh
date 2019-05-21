#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

source /opt/azure/acc/utils.sh

# validate open-enclave package installation
status=$(dpkg -s open-enclave | grep "Status: install ok installed")
if [ $? -ne 0  ] || [ -z "$status" ]; then
  echo "open-enclave is not installed"
  exit 1
fi

# exit on error from this point
set -e
set -o errexit

# set logfile
readonly LOG_FILE="/opt/azure/acc/validation.log"
set -x
touch $LOG_FILE
exec 1>$LOG_FILE
exec 2>&1

# copy samples
tempdir="$(mktemp -d)"
trap "rm -rf \"${tempdir}\"" EXIT
cp -r /opt/openenclave/share/openenclave/samples/ $tempdir

# build and run all samples except remote_attestation
if [ -e /opt/openenclave/share/openenclave/openenclaverc ]; then
  source /opt/openenclave/share/openenclave/openenclaverc
else
  source /opt/openenclave/share/openenclaverc
fi
cd $tempdir/samples

export OE_LOG_LEVEL=INFO
find . -maxdepth 1 -type d -not -path "*remote_attestation" -not -path "." -exec sh -c "echo Running {}; cd {} && make && make run" \;

echo "open-enclave validation completed $msg"
