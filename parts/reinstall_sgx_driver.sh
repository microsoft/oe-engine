#!/bin/bash

set -e

current_kernel_ver=$(uname -r)
last_kernel_ver=
if [ -e /opt/azure/acc/sgx_kernel_version ];  then
  last_kernel_ver=$(cat /opt/azure/acc/sgx_kernel_version)
fi

echo "current_kernel_ver=${current_kernel_ver} last_kernel_ver=${last_kernel_ver}"

if [ "${current_kernel_ver}" = "${last_kernel_ver}" ]; then
  echo "kernel has not updated. skipping SGX driver update"
  exit 0
fi

/opt/azure/acc/sgx_linux_x64_driver_dcap_a06cb75.bin

echo ${current_kernel_ver} > /opt/azure/acc/sgx_kernel_version

echo "SGX driver has been updated for ${current_kernel_ver}"
