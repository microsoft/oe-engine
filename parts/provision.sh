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

source /opt/azure/acc/provision_source.sh

cd /opt/azure/acc/

OE_PKG_BASE="PACKAGE_BASE_URL"

# Check to see this is an openenclave supporting hardware environment
retrycmd_if_failure 10 10 120 curl -fsSL -o oesgx "$OE_PKG_BASE/oesgx"
chmod a+x ./oesgx

./oesgx | grep "does not support"
if [ $? -eq 0 ] ; then
    echo "This hardware does not support open enclave"
    exit -1
fi

# Update pkg repository
retrycmd_if_failure 10 10 120 apt update
if [ $? -ne 0  ]; then
  exit 1
fi

# Install public packages:

# Needed for Open Enclave build and scripts
PACKAGES="clang-format cmake gcc g++ make libcurl3"

# Needed for using oedbg
PACKAGES="$PACKAGES gdb"

# Needed for 3rdparty/libunwind
PACKAGES="$PACKAGES autoconf libtool"

# Needed to generate documentation during make
PACKAGES="$PACKAGES doxygen graphviz"

# Needed for cmake/get_c_compiler_dir.sh
PACKAGES="$PACKAGES gawk"

# Needed for dox2md document generation
PACKAGES="$PACKAGES libexpat1-dev"

# Needed for oesign
PACKAGES="$PACKAGES openssl"

# Needed for oehost
PACKAGES="$PACKAGES libssl-dev"

retrycmd_if_failure 10 10 120 apt-get -y install $PACKAGES

# Install OE packages
OE_PACKAGES=(
  libsgx-enclave-common_1.0.101.45575-1.0_amd64.deb
  libsgx-enclave-common-dev_1.0.101.45575-1.0_amd64.deb
  libsgx-ngsa-ql_1.0.101.45575-1.0_amd64.deb
  libsgx-ngsa-ql-dev_1.0.101.45575-1.0_amd64.deb
  azquotprov_0.2-1_amd64.deb
  open-enclave-0.2.0-Linux.deb
)

for pkg in ${OE_PACKAGES[@]}; do
  retry_get_install_deb 10 10 120 "$OE_PKG_BASE/$pkg"
done

# Install SGX driver
retrycmd_if_failure 10 10 120 curl -fsSL -o sgx_linux_x64_driver.bin "$OE_PKG_BASE/sgx_linux_x64_driver.bin"
chmod a+x ./sgx_linux_x64_driver.bin
./sgx_linux_x64_driver.bin
