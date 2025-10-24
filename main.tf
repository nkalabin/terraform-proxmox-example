provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.username
  password = var.password
  insecure = var.insecure
}

resource "proxmox_virtual_environment_vm" "debian_vms" {
  count           = length(var.vms)
  name            = var.vms[count.index].name
  node_name       = var.node_name
  stop_on_destroy = true

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.debian_base_cloud_config[count.index].id
  }

  cpu {
    cores = var.vms[count.index].cores
    type  = "host"
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  serial_device {
    device = "socket"
  }

  memory {
    dedicated = var.vms[count.index].memory
    floating  = var.vms[count.index].memory
  }

  network_device {
    bridge  = var.bridge
    vlan_id = var.vlan_id
    model   = "virtio"
  }

  disk {
    datastore_id = var.datastore_for_vm_disk
    import_from  = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "ignore"
    cache        = "none"
    replicate    = false
    size         = var.vms[count.index].disk_size
  }
}
resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = var.datastore_for_cloud_init
  node_name    = var.node_name
  url          = "https://cdimage.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

resource "proxmox_virtual_environment_file" "debian_base_cloud_config" {
  count        = length(var.vms)
  content_type = "snippets"
  datastore_id = var.datastore_for_cloud_init
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}${var.cloud_init_file}", {
      fqdn = var.vms[count.index].name
    })

    file_name = "${var.vms[count.index].name}-default.yaml"
  }
}
