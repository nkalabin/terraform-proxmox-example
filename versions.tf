terraform {
  required_version = ">= 1.0"
  
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
  
  # Backend configuration (uncomment and configure for remote state)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "proxmox/terraform.tfstate"
  #   region = "us-west-2"
  # }
}
