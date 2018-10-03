#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

source /opt/azure/acc/utils.sh

# Install required packages.
#

cd /opt/azure/acc/

OE_PKG_BASE="PACKAGE_BASE_URL"

function error_exit() {
  echo $1
  exit 1
}
# Check to see this is an openenclave supporting hardware environment
retrycmd_if_failure 10 10 120 curl -fsSL -o oesgx "$OE_PKG_BASE/oesgx"
chmod a+x ./oesgx

./oesgx | grep "does not support"
if [ $? -eq 0 ] ; then
  error_exit "This hardware does not support open enclave"
fi

# Configure apt to use clang-7
echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main" >> /etc/apt/sources.list
echo "deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main" >> /etc/apt/sources.list
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -

# Configure apt to use packages.microsoft.com repo
echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/16.04/prod xenial main" | sudo tee /etc/apt/sources.list.d/msprod.list
wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Configure apt to use Intel 01.org repo
echo "deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/intel-sgx.list
wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | sudo apt-key add -

export DEBIAN_FRONTEND=noninteractive

# Update pkg repository
retrycmd_if_failure 10 10 120 apt update
if [ $? -ne 0  ]; then
  error_exit "apt update failed"
fi

# Add public packages:
PACKAGES="make gcc gdb g++ libssl-dev"

# Add clang-7 packages:
PACKAGES="$PACKAGES clang-7 lldb-7 lld-7"

# Add Intel packages
PACKAGES="$PACKAGES libsgx-enclave-common libsgx-enclave-common-dev libsgx-dcap-ql libsgx-dcap-ql-dev"

# Add Microsoft packages
PACKAGES="$PACKAGES az-dcap-client"

retrycmd_if_failure 10 10 120 apt-get -y install $PACKAGES
if [ $? -ne 0  ]; then
  error_exit "apt-get install failed"
fi

# Install OE package
retry_get_install_deb 10 10 120 "$OE_PKG_BASE/open-enclave-0.4.0-Linux.deb"
if [ $? -ne 0  ]; then
  error_exit "failed to install OE SDK package"
fi

systemctl disable aesmd
systemctl stop aesmd

# Install SGX driver
retrycmd_if_failure 10 10 120 curl -fsSL -O https://download.01.org/intel-sgx/dcap-1.0/sgx_linux_x64_driver_dcap_36594a7.bin
if [ $? -ne 0  ]; then
  error_exit "failed to download SGX driver"
fi
chmod a+x ./sgx_linux_x64_driver_dcap_36594a7.bin
./sgx_linux_x64_driver_dcap_36594a7.bin
if [ $? -ne 0  ]; then
  error_exit "failed to install SGX driver"
fi

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

# build and run samples
cd $tempdir/samples
make
make run

echo "open-enclave validation succedded"
