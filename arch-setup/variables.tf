variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://your-proxmox-server:8006/api2/json"
}

variable "proxmox_user" {
  description = "Proxmox username (for API token: token_id)"
  type        = string
  default     = "terraform@pve!mytoken"
}

variable "proxmox_password" {
  description = "Proxmox password (for API token: token_secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key for VMs"
  type        = string
  default     = ""
}

variable "ssh_private_key" {
  description = "SSH private key for VMs"
  type        = string
  sensitive   = true
  default     = ""
}

variable "network_gateway" {
  description = "Network gateway IP"
  type        = string
  default     = "192.168.1.1"
}

variable "network_subnet" {
  description = "Network subnet (CIDR)"
  type        = string
  default     = "192.168.1.0/24"
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}