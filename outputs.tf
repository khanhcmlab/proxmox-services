# VM IP addresses
output "vm_ips" {
  description = "IP addresses of all VMs"
  value = {
    for name, vm in proxmox_virtual_environment_vm.ubuntu_vms :
    name => try(vm.ipv4_addresses[1][0], "Not available yet")
  }
}

# VM IDs
output "vm_ids" {
  description = "VM IDs of all VMs"
  value = {
    for name, vm in proxmox_virtual_environment_vm.ubuntu_vms : name => vm.vm_id
  }
}

# VM names
output "vm_names" {
  description = "Names of all VMs"
  value = {
    for name, vm in proxmox_virtual_environment_vm.ubuntu_vms : name => vm.name
  }
}

# Static IP configuration
output "static_ip_config" {
  description = "Static IP configuration for all VMs"
  value = {
    for name, config in local.vms : name => {
      ip_address = config.ip_address
      node       = config.node_name
      vm_id      = config.vm_id
    }
  }
}

# SSH connection information
output "ssh_connections" {
  description = "SSH connection commands for all VMs"
  value = {
    for name, config in local.vms : name => "ssh ubuntu@${split("/", config.ip_address)[0]}"
  }
}

# VM summary
output "vm_summary" {
  description = "Complete VM information"
  value = {
    for name, config in local.vms : name => {
      hostname   = name
      node       = config.node_name
      vm_id      = config.vm_id
      cpu_cores  = config.cpu_cores
      memory_mb  = config.memory
      disk_gb    = config.disk_size
      ip_address = config.ip_address
      ssh_cmd    = "ssh ubuntu@${split("/", config.ip_address)[0]}"
    }
  }
}