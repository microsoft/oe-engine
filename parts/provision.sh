#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Install required packages.
#

source /opt/azure/acc/utils.sh

cd /opt/azure/acc/

OE_PKG_BASE="PACKAGE_BASE_URL"

function error_exit() {
  echo $1
  echo "failed" > /opt/azure/acc/completed
  exit 1
}

function setup_ubuntu() {
  release=$(lsb_release -cs)

  # Configure apt to use clang-7
  echo "deb http://apt.llvm.org/$release/ llvm-toolchain-$release-7 main" >> /etc/apt/sources.list
  echo "deb-src http://apt.llvm.org/$release/ llvm-toolchain-$release-7 main" >> /etc/apt/sources.list
  wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -

  # Configure apt to use packages.microsoft.com repo
  echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/$version/prod $release main" | sudo tee /etc/apt/sources.list.d/msprod.list
  wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

  # Configure apt to use Intel 01.org repo
  echo "deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu $release main" | sudo tee /etc/apt/sources.list.d/intel-sgx.list
  wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | sudo apt-key add -

  export DEBIAN_FRONTEND=noninteractive

  case $version in
    "18.04")
      ;;
    "16.04")
      ;;
    "*")
      error_exit "Version $version is not supported"
      ;;
  esac

  # Update pkg repository
  retrycmd_if_failure 10 10 120 apt update
  if [ $? -ne 0  ]; then
    error_exit "apt update failed"
  fi

  # Add public packages:
  PACKAGES="make gcc gdb g++ libssl-dev pkg-config"

  # Add clang-7 packages:
  PACKAGES="$PACKAGES clang-7 lldb-7 lld-7"

  retrycmd_if_failure 10 10 120 apt-get -y install $PACKAGES
  if [ $? -ne 0  ]; then
    error_exit "apt-get install failed"
  fi
}

distro=`grep DISTRIB_ID /etc/*-release | cut -f 2 -d "="`
version=`grep DISTRIB_RELEASE /etc/*-release| cut -f 2 -d "="`
case $distro in
  "Ubuntu")
    setup_ubuntu
    ;;
  *)
    error_exit "Distro $distro is not currently supported"
  ;;
esac

# Install SGX driver
sgx_driver="sgx_linux_x64_driver_dcap_a06cb75.bin"
sgx_driver_url="${OE_PKG_BASE}/${sgx_driver}"

retrycmd_if_failure 10 10 120 curl -fsSL -O ${sgx_driver_url}
if [ $? -ne 0  ]; then
  error_exit "failed to download SGX driver"
fi
chmod a+x ./${sgx_driver}
./${sgx_driver}
if [ $? -ne 0  ]; then
  error_exit "failed to install SGX driver"
fi

# Save kernel version for SGX driver
uname -r > /opt/azure/acc/sgx_kernel_version

# Enable cron job to rebuild SGX driver if needed
echo "@reboot root /opt/azure/acc/reinstall_sgx_driver.sh" >> /etc/crontab

# Add Intel packages
PACKAGES="libsgx-enclave-common libsgx-enclave-common-dev libsgx-dcap-ql libsgx-dcap-ql-dev"

# Add Microsoft packages
PACKAGES="$PACKAGES az-dcap-client open-enclave"

retrycmd_if_failure 10 10 120 apt-get -y install $PACKAGES
if [ $? -ne 0  ]; then
  error_exit "apt-get install failed"
fi

systemctl disable aesmd
systemctl stop aesmd

# Check to see this is an openenclave supporting hardware environment
/opt/openenclave/bin/oesgx | grep "does not support"
if [ $? -eq 0 ] ; then
  error_exit "This hardware does not support open enclave"
fi

# Indicate readiness
echo "ok" > /opt/azure/acc/completed
