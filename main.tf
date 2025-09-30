# VM Configuration Locals
locals {
  vms = {
    "control-plane-1" = {
      node_name = "hp"
      vm_id     = 110
      cpu_cores = 1
      memory    = 4096
      disk_size = 50
      ip_address = "192.168.1.110/24"
    }
    "worker-1" = {
      node_name = "hp"
      vm_id     = 111
      cpu_cores = 3
      memory    = 28672
      disk_size = 50
      ip_address = "192.168.1.111/24"
    }
    "control-plane-2" = {
      node_name = "gl552"
      vm_id     = 112
      cpu_cores = 1
      memory    = 3072
      disk_size = 25
      ip_address = "192.168.1.112/24"
    }
    "worker-2" = {
      node_name = "gl552"
      vm_id     = 113
      cpu_cores = 3
      memory    = 5120
      disk_size = 25
      ip_address = "192.168.1.113/24"
    }
    "control-plane-3" = {
      node_name = "pve"
      vm_id     = 114
      cpu_cores = 1
      memory    = 4096
      disk_size = 25
      ip_address = "192.168.1.114/24"
    }
    "worker-3" = {
      node_name = "pve"
      vm_id     = 115
      cpu_cores = 3
      memory    = 12288
      disk_size = 25
      ip_address = "192.168.1.115/24"
    }
  }
}

# Ubuntu VMs
resource "proxmox_virtual_environment_vm" "ubuntu_vms" {
  for_each = local.vms

  name      = each.key
  node_name = each.value.node_name
  vm_id     = each.value.vm_id

  # VM Configuration
  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  # Boot configuration
  boot_order = ["scsi0"]

  # SCSI Controller
  scsi_hardware = "virtio-scsi-pci"

  # Hard disk (clone from Ubuntu cloud image)
  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/ubuntu-24.04-minimal-cloudimg-amd64.img"
    interface    = "scsi0"
    iothread     = true
    size         = each.value.disk_size
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

  # Cloud-init configuration
  initialization {
    datastore_id = "local-lvm"
    
    user_account {
      username = "ubuntu"
      password = "ubuntu"
      keys     = []
    }

    ip_config {
      ipv4 {
        address = each.value.ip_address
        gateway = "192.168.1.1"
      }
    }

    dns {
      servers = ["8.8.8.8", "8.8.4.4"]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_config[each.key].id
  }

  # Lifecycle
  started = true
  on_boot = true
}

# Cloud-init configuration files
resource "proxmox_virtual_environment_file" "cloud_init_config" {
  for_each = local.vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = each.value.node_name

  source_raw {
    data = yamlencode({
      "#cloud-config" = {}
      hostname        = each.key
      manage_etc_hosts = true
      
      users = [{
        name                = "ubuntu"
        groups              = ["adm", "sudo"]
        shell               = "/bin/bash"
        sudo                = "ALL=(ALL) NOPASSWD:ALL"
        lock_passwd         = false
        passwd              = "$6$rounds=4096$3n.TcfNOJGpIOXx4$QasQZyItSIK8.mXD.C/V4B5lc0p9Qn5h3GYBwShF.lFfxLJ3gUGcjPJIXe.zNnEr6zLg6nLvDlcL2U3h7S/4E0"  # password: ubuntu
        ssh_authorized_keys = []
      }]

      package_update = true
      package_upgrade = true

      packages = [
        "curl",
        "wget",
        "git",
        "htop",
        "net-tools",
        "openssh-server",
        "qemu-guest-agent"
      ]

      runcmd = [
        "systemctl enable qemu-guest-agent",
        "systemctl start qemu-guest-agent",
        "systemctl enable ssh",
        "systemctl start ssh"
      ]

      power_state = {
        mode = "reboot"
        condition = true
      }
    })

    file_name = "${each.key}-cloud-init.yaml"
  }
}