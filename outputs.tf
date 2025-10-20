# VM Information
output "vm_id" {
  description = "Virtual Machine ID"
  value       = proxmox_vm_qemu.vm.vmid
}

output "vm_name" {
  description = "Virtual Machine name"
  value       = proxmox_vm_qemu.vm.name
}

output "vm_ip_address" {
  description = "Virtual Machine IP address"
  value       = proxmox_vm_qemu.vm.default_ipv4_address
  sensitive   = false
}

output "vm_mac_address" {
  description = "Virtual Machine MAC address"
  value       = proxmox_vm_qemu.vm.network[0].macaddr
}

# VM Resources
output "vm_cpu_cores" {
  description = "Number of CPU cores"
  value       = proxmox_vm_qemu.vm.cpu[0].cores
}

output "vm_memory_mb" {
  description = "Memory allocated in MB"
  value       = proxmox_vm_qemu.vm.memory
}

# Connection Information
output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh ${var.vm_user}@${proxmox_vm_qemu.vm.default_ipv4_address}"
}

output "vm_startup" {
  description = "Virtual Machine startup configuration"
  value       = proxmox_vm_qemu.vm.startup
}

# Proxmox Information
output "proxmox_node" {
  description = "Proxmox node where VM is running"
  value       = proxmox_vm_qemu.vm.target_node
}
