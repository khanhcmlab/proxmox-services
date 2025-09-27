# First VM - Small configuration (1 core, 4GB RAM)
resource "proxmox_virtual_environment_vm" "vm_small" {
  name        = "control-plane-1"
  node_name   = "hp"
  vm_id       = 110
  
  # VM Configuration
  cpu {
    cores = 1
    type  = "host"
  }
  
  memory {
    dedicated = 4096
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
    size         = 50
  }
  
  # CD-ROM with ISO
  cdrom {
    enabled   = true
    file_id   = "local:iso/archlinux-2025.08.01-x86_64.iso"
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

# Second VM - Large configuration (3 cores, 28GB RAM)
resource "proxmox_virtual_environment_vm" "vm_large" {
  name        = "worker-1"
  node_name   = "hp"
  vm_id       = 111
  
  # VM Configuration
  cpu {
    cores = 3
    type  = "host"
  }
  
  memory {
    dedicated = 28672  # 28GB in MB
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
    size         = 50
  }
  
  # CD-ROM with ISO
  cdrom {
    enabled   = true
    file_id   = "local:iso/archlinux-2025.08.01-x86_64.iso"
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

# Third VM - Control Plane 2 (1 core, 3GB RAM)
resource "proxmox_virtual_environment_vm" "control_plane_2" {
  name        = "control-plane-2"
  node_name   = "gl552"
  vm_id       = 112
  
  # VM Configuration
  cpu {
    cores = 1
    type  = "host"
  }
  
  memory {
    dedicated = 3072  # 3GB in MB
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
    size         = 25
  }
  
  # CD-ROM with ISO
  cdrom {
    enabled   = true
    file_id   = "local:iso/archlinux-2025.08.01-x86_64.iso"
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

# Fourth VM - Worker 2 (3 cores, 5GB RAM)
resource "proxmox_virtual_environment_vm" "worker_2" {
  name        = "worker-2"
  node_name   = "gl552"
  vm_id       = 113
  
  # VM Configuration
  cpu {
    cores = 3
    type  = "host"
  }
  
  memory {
    dedicated = 5120  # 5GB in MB
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
    size         = 25
  }
  
  # CD-ROM with ISO
  cdrom {
    enabled   = true
    file_id   = "local:iso/archlinux-2025.08.01-x86_64.iso"
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

# Fifth VM - Control Plane 3 (1 core, 4GB RAM)
resource "proxmox_virtual_environment_vm" "control_plane_3" {
  name        = "control-plane-3"
  node_name   = "pve"
  vm_id       = 114
  
  # VM Configuration
  cpu {
    cores = 1
    type  = "host"
  }
  
  memory {
    dedicated = 4096  # 4GB in MB
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
    size         = 25
  }
  
  # CD-ROM with ISO
  cdrom {
    enabled   = true
    file_id   = "local:iso/archlinux-2025.08.01-x86_64.iso"
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

# Sixth VM - Worker 3 (3 cores, 12GB RAM)
resource "proxmox_virtual_environment_vm" "worker_3" {
  name        = "worker-3"
  node_name   = "pve"
  vm_id       = 115
  
  # VM Configuration
  cpu {
    cores = 3
    type  = "host"
  }
  
  memory {
    dedicated = 12288  # 12GB in MB
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
    size         = 25
  }
  
  # CD-ROM with ISO
  cdrom {
    enabled   = true
    file_id   = "local:iso/archlinux-2025.08.01-x86_64.iso"
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