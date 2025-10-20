# Proxmox Provider Configuration
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = false
}

# VM Configuration
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "debian-vm"
}

variable "vm_description" {
  description = "Description of the virtual machine"
  type        = string
  default     = "Debian 13 VM created with Terraform"
}

variable "target_node" {
  description = "Proxmox node name where VM will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.target_node))
    error_message = "Target node name must contain only alphanumeric characters and hyphens."
  }
}

variable "template_name" {
  description = "Name of the template to clone from"
  type        = string
  default     = "debian-13-template"
}

variable "storage_name" {
  description = "Storage name for VM disks"
  type        = string
}

# VM Resources
variable "vm_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
  validation {
    condition     = var.vm_cores > 0 && var.vm_cores <= 32
    error_message = "CPU cores must be between 1 and 32."
  }
}

variable "vm_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
  validation {
    condition     = var.vm_sockets > 0 && var.vm_sockets <= 8
    error_message = "CPU sockets must be between 1 and 8."
  }
}

variable "vm_memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
  validation {
    condition     = var.vm_memory >= 512 && var.vm_memory <= 131072
    error_message = "Memory must be between 512MB and 128GB."
  }
}

variable "vm_disk_size" {
  description = "Disk size in GB"
  type        = string
  default     = "20"
  validation {
    condition     = can(regex("^[0-9]+G$", var.vm_disk_size))
    error_message = "Disk size must be specified in format like '20G'."
  }
}

# Network Configuration
variable "vm_bridge" {
  description = "Network bridge for VM"
  type        = string
  default     = "vmbr0"
}

variable "vm_vlan_tag" {
  description = "VLAN tag for VM network"
  type        = number
  default     = null
}

# Cloud-init Configuration
variable "vm_user" {
  description = "Default user for cloud-init"
  type        = string
  default     = "cm"
}

variable "vm_password" {
  description = "Password for the default user"
  type        = string
  default     = null
  sensitive   = true
}

variable "vm_ssh_keys" {
  description = "SSH public keys for the default user"
  type        = string
  default     = null
}

variable "vm_nameserver" {
  description = "Nameserver for VM"
  type        = string
  default     = "8.8.8.8"
}

variable "vm_ip_config" {
  description = "IP configuration for VM (dhcp or static)"
  type        = string
  default     = "dhcp"
  validation {
    condition     = contains(["dhcp", "static"], var.vm_ip_config)
    error_message = "IP config must be either 'dhcp' or 'static'."
  }
}

variable "vm_cloud_init_custom" {
  description = "Custom cloud-init configuration"
  type        = string
  default     = null
}


# Tags and Labels
variable "vm_tags" {
  description = "Tags for the virtual machine"
  type        = list(string)
  default     = ["terraform", "debian"]
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
