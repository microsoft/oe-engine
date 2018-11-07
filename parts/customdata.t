runcmd:
- /opt/azure/acc/provision.sh
write_files:
- content: 'UTILS_STR'
  path: /opt/azure/acc/utils.sh
  permissions: "0744"
  owner: "root"
- content: 'PROVISION_STR'
  path: /opt/azure/acc/provision.sh
  permissions: "0744"
  owner: "root"
- content: 'VALIDATION_STR'
  path: /opt/azure/acc/validate.sh
  permissions: "0744"
  owner: "root"
- content: 'REINSTALL_SGX_STR'
  path: /opt/azure/acc/reinstall_sgx_driver.sh
  permissions: "0744"
  owner: "root"
  