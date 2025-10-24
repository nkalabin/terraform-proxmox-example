output "vm_info" {
  description = "VM names and their IP addresses"
  value = {
    for vm in proxmox_virtual_environment_vm.debian_vms :
    vm.name => vm.ipv4_addresses[1]
  }
}
