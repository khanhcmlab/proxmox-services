# Network configuration for VMs
locals {
  vm_configs = {
    "control-plane-1" = {
      hostname = "control-plane-1"
      ip       = "192.168.1.110"
      node     = "hp"
    }
    "worker-1" = {
      hostname = "worker-1"
      ip       = "192.168.1.111" 
      node     = "hp"
    }
    "control-plane-2" = {
      hostname = "control-plane-2"
      ip       = "192.168.1.112"
      node     = "gl552"
    }
    "worker-2" = {
      hostname = "worker-2"
      ip       = "192.168.1.113"
      node     = "gl552"
    }
    "control-plane-3" = {
      hostname = "control-plane-3"
      ip       = "192.168.1.114"
      node     = "pve"
    }
    "worker-3" = {
      hostname = "worker-3"
      ip       = "192.168.1.115"
      node     = "pve"
    }
  }
}

