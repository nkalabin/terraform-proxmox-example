terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.1"
    }
  }

  # Backend configuration (uncomment and configure for remote state)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "proxmox/terraform.tfstate"
  #   region = "us-west-2"
  # }
}
