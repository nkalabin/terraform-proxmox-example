# =============================================================================
# PROXMOX TERRAFORM MODULE
# Создание VM из шаблона в Proxmox
# =============================================================================

# Provider Configuration - настройки в terraform.tfvars
provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = var.proxmox_tls_insecure
}


# Virtual Machine Resource - настройки в terraform.tfvars
resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name          # ИЗМЕНИТЕ: имя VM в terraform.tfvars
  description = var.vm_description
  target_node = var.target_node      # ИЗМЕНИТЕ: узел Proxmox в terraform.tfvars
  clone       = var.template_name    # ИЗМЕНИТЕ: имя шаблона в terraform.tfvars

  # VM Configuration - базовые настройки
  agent    = 1                       # Включить QEMU guest agent
  os_type  = "cloud-init"            # Тип ОС для cloud-init
  memory   = var.vm_memory           # ИЗМЕНИТЕ: память в terraform.tfvars
  scsihw   = "virtio-scsi-single"    # SCSI контроллер
  bios     = "seabios"               # BIOS (seabios или ovmf)
  full_clone = true                  # Полное клонирование шаблона
  
  # CPU Configuration
  cpu {
    type    = "host"
    cores   = var.vm_cores
    sockets = var.vm_sockets
  }

  # Disk Configuration - клонирование диска шаблона и cloud-init
  disks {
    # Диск шаблона будет клонирован как scsi0
    scsi {
      scsi0 {
        disk {
          size = var.vm_disk_size        # ИЗМЕНИТЕ: размер диска в terraform.tfvars
          storage = var.storage_name     # ИЗМЕНИТЕ: хранилище в terraform.tfvars
          format = "raw"                 # Формат диска (raw, qcow2)
        }
      }
    }
    # Cloud-init диск
    ide {
      ide3 {
        cloudinit {
          storage = var.storage_name     # ИЗМЕНИТЕ: хранилище в terraform.tfvars
        }
      }
    }
  }

  # Network Configuration - сетевые настройки
  network {
    id     = 0                          # ID сетевого интерфейса
    model  = "virtio"                   # Модель сетевой карты (virtio, e1000, rtl8139)
    bridge = var.vm_bridge              # ИЗМЕНИТЕ: сетевой мост в terraform.tfvars
    tag    = var.vm_vlan_tag            # ИЗМЕНИТЕ: VLAN тег в terraform.tfvars
  }

  # Boot Configuration - загрузка с диска шаблона
  boot = "order=scsi0"                  # ИЗМЕНИТЕ: если шаблон использует другой диск

  # Cloud-init Configuration - настройки пользователя и сети
  ipconfig0  = var.vm_ip_config         # ИЗМЕНИТЕ: IP конфигурация в terraform.tfvars
  nameserver = var.vm_nameserver        # ИЗМЕНИТЕ: DNS сервер в terraform.tfvars
  ciuser     = var.vm_user              # ИЗМЕНИТЕ: имя пользователя в terraform.tfvars
  
  # Additional cloud-init settings
  cicustom = var.vm_cloud_init_custom   # ИЗМЕНИТЕ: кастомные cloud-init настройки
  cipassword = var.vm_password          # ИЗМЕНИТЕ: пароль в terraform.tfvars
  sshkeys = var.vm_ssh_keys != null ? var.vm_ssh_keys : null  # ИЗМЕНИТЕ: SSH ключи

  # Tags
  tags = join(";", var.vm_tags)

  # Lifecycle rules
  lifecycle {
    ignore_changes = [
      # Ignore changes to network interface MAC address
      network,
      # Ignore changes to disk size after creation
      disks,
    ]
  }

  # Ensure VM is stopped before destroying
  onboot = false
}
