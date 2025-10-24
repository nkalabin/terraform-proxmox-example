#Auth
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "username" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "insecure" {
  description = "Proxmox API URL"
  type        = bool
}
#VM Settings 
variable "vms" {
  description = "List of VMs to create"
  type = list(object({
    name      = string
    cores     = number
    memory    = number
    disk_size = number
  }))
}

variable "vlan_id" {
  description = "Proxmox vlan id"
  type        = number
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "bridge" {
  description = "Network bridge"
  type        = string
}

variable "datastore_for_cloud_init" {
  description = "Datastore for cloud-init files"
  type        = string
}

variable "datastore_for_vm_disk" {
  description = "Datastore for VM disks"
  type        = string
}

variable "cloud_init_file" {
  description = "Cloud-init template file path"
  type        = string
}
