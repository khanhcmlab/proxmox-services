terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.63"
    }
  }
  required_version = ">= 1.0"
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  api_token = "${var.proxmox_user}=${var.proxmox_password}"
  insecure = var.proxmox_tls_insecure
}