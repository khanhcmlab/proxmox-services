# Talos Machine Secrets
resource "talos_machine_secrets" "machine_secrets" {
  talos_version = "v1.8"
}

# First we need to get the dynamic IP of the first control plane
# We'll use a data source to get the VM info after it's created
data "talos_machine_configuration" "controlplane" {
  cluster_name     = "talos-cluster"
  cluster_endpoint = "https://${try(proxmox_virtual_environment_vm.talos_control_planes["talos-control-plane-1"].ipv4_addresses[1][0], "127.0.0.1")}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = "talos-cluster" 
  cluster_endpoint = "https://${try(proxmox_virtual_environment_vm.talos_control_planes["talos-control-plane-1"].ipv4_addresses[1][0], "127.0.0.1")}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# Talos Client Configuration - will be populated after VMs are created
data "talos_client_configuration" "talosconfig" {
  depends_on = [proxmox_virtual_environment_vm.talos_control_planes]
  
  cluster_name         = "talos-cluster"
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints = [
    for vm in proxmox_virtual_environment_vm.talos_control_planes : 
    try(vm.ipv4_addresses[1][0], "127.0.0.1")
  ]
}

# Generate machine-specific configurations with static IPs
locals {
  # Control plane configurations with dynamic IPs
  controlplane_configs = {
    "talos-control-plane-1" = {
      hostname = "talos-control-plane-1"
      node     = "hp"
      vm_id    = 120
      memory   = 4096
      disk     = 50
      cpu      = 1
    }
    "talos-control-plane-2" = {
      hostname = "talos-control-plane-2"
      node     = "gl552"
      vm_id    = 122
      memory   = 3072
      disk     = 25
      cpu      = 1
    }
    "talos-control-plane-3" = {
      hostname = "talos-control-plane-3"
      node     = "pve"
      vm_id    = 124
      memory   = 4096
      disk     = 25
      cpu      = 1
    }
  }

  # Worker configurations with dynamic IPs
  worker_configs = {
    "talos-worker-1" = {
      hostname = "talos-worker-1"
      node     = "hp"
      vm_id    = 121
      memory   = 28672
      disk     = 50
      cpu      = 3
    }
    "talos-worker-2" = {
      hostname = "talos-worker-2"
      node     = "gl552"
      vm_id    = 123
      memory   = 5120
      disk     = 25
      cpu      = 3
    }
    "talos-worker-3" = {
      hostname = "talos-worker-3"
      node     = "pve"
      vm_id    = 125
      memory   = 12288
      disk     = 25
      cpu      = 3
    }
  }

  # Network configuration for all machines (DHCP-based)
  network_config = {
    nameservers = ["8.8.8.8", "8.8.4.4"]
  }
}

# Generate machine-specific configurations with DHCP
data "talos_machine_configuration" "controlplane_dhcp" {
  for_each = local.controlplane_configs

  cluster_name     = "talos-cluster"
  cluster_endpoint = "https://${try(proxmox_virtual_environment_vm.talos_control_planes["talos-control-plane-1"].ipv4_addresses[1][0], "127.0.0.1")}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.hostname
          interfaces = [{
            interface = "ens18"
            dhcp = true
          }]
          nameservers = local.network_config.nameservers
        }
        install = {
          disk = "/dev/sda"
        }
      }
      cluster = {
        apiServer = {
          certSANs = [each.value.hostname]
        }
      }
    })
  ]
}

data "talos_machine_configuration" "worker_dhcp" {
  for_each = local.worker_configs

  cluster_name     = "talos-cluster"
  cluster_endpoint = "https://${try(proxmox_virtual_environment_vm.talos_control_planes["talos-control-plane-1"].ipv4_addresses[1][0], "127.0.0.1")}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.hostname
          interfaces = [{
            interface = "ens18"
            dhcp = true
          }]
          nameservers = local.network_config.nameservers
        }
        install = {
          disk = "/dev/sda"
        }
      }
    })
  ]
}

# Proxmox VMs - Control Planes
resource "proxmox_virtual_environment_vm" "talos_control_planes" {
  for_each = local.controlplane_configs

  name      = each.value.hostname
  node_name = each.value.node
  vm_id     = each.value.vm_id
  
  # VM Configuration
  cpu {
    cores = each.value.cpu
    type  = "host"
  }
  
  memory {
    dedicated = each.value.memory
  }
  
  # Boot configuration
  boot_order = ["scsi0", "ide2"]
  
  # SCSI Controller
  scsi_hardware = "virtio-scsi-pci"
  
  # Hard disk
  disk {
    datastore_id = "local-lvm"
    file_id      = null
    interface    = "scsi0"
    iothread     = true
    size         = each.value.disk
  }
  
  # CD-ROM with Talos ISO
  cdrom {
    file_id   = "local:iso/metal-amd64.iso"
    interface = "ide2"
  }
  
  # Network
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
  
  # VM Settings
  agent {
    enabled = true
  }
  
  operating_system {
    type = "l26"  # Linux 2.6+ kernel
  }
  
  # Lifecycle
  started = true
  on_boot = true
}

# Proxmox VMs - Workers
resource "proxmox_virtual_environment_vm" "talos_workers" {
  for_each = local.worker_configs

  name      = each.value.hostname
  node_name = each.value.node
  vm_id     = each.value.vm_id
  
  # VM Configuration
  cpu {
    cores = each.value.cpu
    type  = "host"
  }
  
  memory {
    dedicated = each.value.memory
  }
  
  # Boot configuration
  boot_order = ["scsi0", "ide2"]
  
  # SCSI Controller
  scsi_hardware = "virtio-scsi-pci"
  
  # Hard disk
  disk {
    datastore_id = "local-lvm"
    file_id      = null
    interface    = "scsi0"
    iothread     = true
    size         = each.value.disk
  }
  
  # CD-ROM with Talos ISO
  cdrom {
    file_id   = "local:iso/metal-amd64.iso"
    interface = "ide2"
  }
  
  # Network
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
  
  # VM Settings
  agent {
    enabled = true
  }
  
  operating_system {
    type = "l26"  # Linux 2.6+ kernel
  }
  
  # Lifecycle
  started = true
  on_boot = true
}

# Apply Talos configurations to control planes (using DHCP IPs)
resource "talos_machine_configuration_apply" "controlplane" {
  for_each = local.controlplane_configs

  depends_on = [proxmox_virtual_environment_vm.talos_control_planes]
  
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane_dhcp[each.key].machine_configuration
  node                       = try(proxmox_virtual_environment_vm.talos_control_planes[each.key].ipv4_addresses[1][0], "127.0.0.1")
  
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.hostname
        }
      }
    })
  ]
}

# Apply Talos configurations to workers (using DHCP IPs)
resource "talos_machine_configuration_apply" "worker" {
  for_each = local.worker_configs

  depends_on = [proxmox_virtual_environment_vm.talos_workers]
  
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker_dhcp[each.key].machine_configuration
  node                       = try(proxmox_virtual_environment_vm.talos_workers[each.key].ipv4_addresses[1][0], "127.0.0.1")
  
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.hostname
        }
      }
    })
  ]
}

# Bootstrap the cluster
resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [talos_machine_configuration_apply.controlplane]
  
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                = try(proxmox_virtual_environment_vm.talos_control_planes["talos-control-plane-1"].ipv4_addresses[1][0], "127.0.0.1")
}

# Generate kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [talos_machine_bootstrap.bootstrap]
  
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                = try(proxmox_virtual_environment_vm.talos_control_planes["talos-control-plane-1"].ipv4_addresses[1][0], "127.0.0.1")
}