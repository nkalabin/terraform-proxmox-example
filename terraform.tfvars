#Auth
proxmox_api_url = "https://192.168.1.1:8006/"
username        = "root@pam"
password        = "password"
insecure        = "true"

#vm setting
vms = [
  {
    name      = "debian13-1"
    cores     = 2
    memory    = 2048
    disk_size = 20
  },
  {
    name      = "debian13-2"
    cores     = 2
    memory    = 2048
    disk_size = 20
  }
]

vlan_id                  = 200
node_name                = "pve"
bridge                   = "mikronet"
datastore_for_cloud_init = "local"
datastore_for_vm_disk    = "local-lvm"
cloud_init_file          = "/cloud-init/default.tftpl"
