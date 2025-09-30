# Network configuration for Talos VMs
locals {
  talos_vm_configs = {
    "talos-control-plane-1" = {
      hostname = "talos-control-plane-1"
      ip       = "192.168.1.120"
      node     = "hp"
    }
    "talos-worker-1" = {
      hostname = "talos-worker-1"
      ip       = "192.168.1.121" 
      node     = "hp"
    }
    "talos-control-plane-2" = {
      hostname = "talos-control-plane-2"
      ip       = "192.168.1.122"
      node     = "gl552"
    }
    "talos-worker-2" = {
      hostname = "talos-worker-2"
      ip       = "192.168.1.123"
      node     = "gl552"
    }
    "talos-control-plane-3" = {
      hostname = "talos-control-plane-3"
      ip       = "192.168.1.124"
      node     = "pve"
    }
    "talos-worker-3" = {
      hostname = "talos-worker-3"
      ip       = "192.168.1.125"
      node     = "pve"
    }
  }
}

