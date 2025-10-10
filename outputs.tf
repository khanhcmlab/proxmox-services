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

# VM configuration details
output "vm_config" {
  description = "VM configuration details"
  value = {
    for name, config in local.vms : name => {
      node   = config.node_name
      vm_id  = config.vm_id
      memory = config.memory
      cpu    = config.cpu_cores
      disk   = config.disk_size
    }
  }
}

# SSH connection information
output "ssh_connections" {
  description = "SSH connection commands for all VMs"
  value = {
    for name, vm in proxmox_virtual_environment_vm.ubuntu_vms :
    name => "ssh ubuntu@${try(vm.ipv4_addresses[1][0], "IP not available yet")}"
  }
}

# VM summary
output "vm_summary" {
  description = "Complete VM information"
  value = {
    for name, vm in proxmox_virtual_environment_vm.ubuntu_vms : name => {
      hostname   = name
      node       = local.vms[name].node_name
      vm_id      = local.vms[name].vm_id
      cpu_cores  = local.vms[name].cpu_cores
      memory_mb  = local.vms[name].memory
      disk_gb    = local.vms[name].disk_size
      ip_address = try(vm.ipv4_addresses[1][0], "IP not available yet")
      ssh_cmd    = "ssh ubuntu@${try(vm.ipv4_addresses[1][0], "IP_not_available_yet")}"
    }
  }
}

# Access instructions
output "access_instructions" {
  description = "Instructions for accessing VMs with dynamic IPs"
  value       = <<-EOT
    📋 To access your VMs with dynamic IP addresses:

    1. Get current IP addresses:
       terraform output vm_ips

    2. Get SSH connection commands:
       terraform output ssh_connections

    3. Connect to a specific VM:
       ssh ubuntu@<dynamic-ip-from-output>

    4. View all VM details:
       terraform output vm_summary

    💡 Remember: IPs are assigned dynamically by DHCP and may change after VM reboots.
    Use the terraform outputs above to get the current IP addresses.
  EOT
}