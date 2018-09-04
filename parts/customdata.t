disk_setup:
  ephemeral0:
    table_type: mbr
    layout: [66, [33, 82]]
    overwrite: True
fs_setup:
  - device: ephemeral0.1
    filesystem: ext4
  - device: ephemeral0.2
    filesystem: swap
mounts:
  - ["ephemeral0.1", "/mnt"]
  - ["ephemeral0.2", "none", "swap", "sw", "0", "0"]
runcmd:
- /opt/azure/acc/provision.sh
write_files:
- content: 'PROVISION_SOURCE_STR'
  path: /opt/azure/acc/provision_source.sh
  permissions: "0744"
  owner: "root"
- content: 'PROVISION_STR'
  path: /opt/azure/acc/provision.sh
  permissions: "0744"
  owner: "root"
