output "vm_small_ip" {
  description = "IP address of the small VM"
  value       = try(proxmox_virtual_environment_vm.vm_small.ipv4_addresses[1][0], "Not available")
}

output "vm_large_ip" {
  description = "IP address of the large VM"
  value       = try(proxmox_virtual_environment_vm.vm_large.ipv4_addresses[1][0], "Not available")
}

output "vm_small_id" {
  description = "VM ID of the small VM"
  value       = proxmox_virtual_environment_vm.vm_small.vm_id
}

output "vm_large_id" {
  description = "VM ID of the large VM"
  value       = proxmox_virtual_environment_vm.vm_large.vm_id
}

output "vm_small_name" {
  description = "Name of the small VM"
  value       = proxmox_virtual_environment_vm.vm_small.name
}

output "vm_large_name" {
  description = "Name of the large VM"
  value       = proxmox_virtual_environment_vm.vm_large.name
}

output "control_plane_2_ip" {
  description = "IP address of control-plane-2"
  value       = try(proxmox_virtual_environment_vm.control_plane_2.ipv4_addresses[1][0], "Not available")
}

output "worker_2_ip" {
  description = "IP address of worker-2"
  value       = try(proxmox_virtual_environment_vm.worker_2.ipv4_addresses[1][0], "Not available")
}

output "control_plane_2_id" {
  description = "VM ID of control-plane-2"
  value       = proxmox_virtual_environment_vm.control_plane_2.vm_id
}

output "worker_2_id" {
  description = "VM ID of worker-2"
  value       = proxmox_virtual_environment_vm.worker_2.vm_id
}

output "control_plane_2_name" {
  description = "Name of control-plane-2"
  value       = proxmox_virtual_environment_vm.control_plane_2.name
}

output "worker_2_name" {
  description = "Name of worker-2"
  value       = proxmox_virtual_environment_vm.worker_2.name
}

output "control_plane_3_ip" {
  description = "IP address of control-plane-3"
  value       = try(proxmox_virtual_environment_vm.control_plane_3.ipv4_addresses[1][0], "Not available")
}

output "worker_3_ip" {
  description = "IP address of worker-3"
  value       = try(proxmox_virtual_environment_vm.worker_3.ipv4_addresses[1][0], "Not available")
}

output "control_plane_3_id" {
  description = "VM ID of control-plane-3"
  value       = proxmox_virtual_environment_vm.control_plane_3.vm_id
}

output "worker_3_id" {
  description = "VM ID of worker-3"
  value       = proxmox_virtual_environment_vm.worker_3.vm_id
}

output "control_plane_3_name" {
  description = "Name of control-plane-3"
  value       = proxmox_virtual_environment_vm.control_plane_3.name
}

output "worker_3_name" {
  description = "Name of worker-3"
  value       = proxmox_virtual_environment_vm.worker_3.name
}