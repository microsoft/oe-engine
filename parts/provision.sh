#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Install required packages.
#

source /opt/azure/acc/utils.sh

cd /opt/azure/acc/

readonly LOG_FILE="/opt/azure/acc/deployment.log"
set -x
touch $LOG_FILE
exec 1>$LOG_FILE
exec 2>&1

function error_exit() {
  echo $1
  echo "failed" > /opt/azure/acc/completed
  exit 1
}

function setup_ubuntu() {
  version=`grep DISTRIB_RELEASE /etc/*-release| cut -f 2 -d "="`

  # Add public packages:
  PACKAGES="make gcc gdb g++ libssl-dev pkg-config dkms"

  case $version in
    "18.04")
      sgx_driver_url="https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntuServer18.04/sgx_linux_x64_driver_1.21.bin"
      PACKAGES="$PACKAGES curl libcurl4 libprotobuf10"
      ;;
    "16.04")
      sgx_driver_url="https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntuServer16.04/sgx_linux_x64_driver_1.21.bin"
      PACKAGES="$PACKAGES libcurl3 libprotobuf9v5"
      ;;
    "*")
      error_exit "Version $version is not supported"
      ;;
  esac
  sgx_driver=$(basename $sgx_driver_url)

  release=$(lsb_release -cs)

  # Configure apt to use clang-7
  echo "deb http://apt.llvm.org/$release/ llvm-toolchain-$release-7 main" | tee /etc/apt/sources.list.d/llvm-toolchain-xenial-7.list
  echo "deb-src http://apt.llvm.org/$release/ llvm-toolchain-$release-7 main" | tee -a /etc/apt/sources.list.d/llvm-toolchain-xenial-7.list
  wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -

  # Configure apt to use packages.microsoft.com repo
  echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/$version/prod $release main" | tee /etc/apt/sources.list.d/msprod.list
  wget -qO - https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

  # Configure apt to use Intel 01.org repo
  echo "deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu $release main" | tee /etc/apt/sources.list.d/intel-sgx.list
  wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add -

  export DEBIAN_FRONTEND=noninteractive

  # Update pkg repository
  retrycmd_if_failure 10 10 120 apt update
  if [ $? -ne 0  ]; then
    error_exit "apt update failed"
  fi

  # Add clang-7 packages:
  PACKAGES="$PACKAGES clang-7 lldb-7 lld-7"

  retrycmd_if_failure 10 10 120 apt-get -y install $PACKAGES
  if [ $? -ne 0  ]; then
    error_exit "apt-get install failed"
  fi

  # Install SGX driver

  retrycmd_if_failure 10 10 120 curl -fsSL -O ${sgx_driver_url}
  if [ $? -ne 0  ]; then
    error_exit "failed to download SGX driver"
  fi
  chmod a+x ./${sgx_driver}
  ./${sgx_driver}
  if [ $? -ne 0  ]; then
    error_exit "failed to install SGX driver"
  fi

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
}

distro=`grep DISTRIB_ID /etc/*-release | cut -f 2 -d "="`

case $distro in
  "Ubuntu")
    setup_ubuntu
    ;;
  *)
    error_exit "Distro $distro is not currently supported"
  ;;
esac


# Check to see this is an openenclave supporting hardware environment
/opt/openenclave/bin/oesgx | grep "does not support"
if [ $? -eq 0 ] ; then
  error_exit "This hardware does not support open enclave"
fi

# Indicate readiness
echo "ok" > /opt/azure/acc/completed
