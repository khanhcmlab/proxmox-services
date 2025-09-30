# Dynamic IP addresses for all nodes
output "control_plane_ips" {
  description = "Dynamic IP addresses of control plane nodes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.talos_control_planes : 
    name => try(vm.ipv4_addresses[1][0], "Not available yet")
  }
}

output "worker_ips" {
  description = "Dynamic IP addresses of worker nodes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.talos_workers : 
    name => try(vm.ipv4_addresses[1][0], "Not available yet")
  }
}

# VM IDs for control planes
output "control_plane_vm_ids" {
  description = "VM IDs of control plane nodes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.talos_control_planes : name => vm.vm_id
  }
}

# VM IDs for workers
output "worker_vm_ids" {
  description = "VM IDs of worker nodes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.talos_workers : name => vm.vm_id
  }
}

# VM names for control planes
output "control_plane_names" {
  description = "Names of control plane nodes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.talos_control_planes : name => vm.name
  }
}

# VM names for workers
output "worker_names" {
  description = "Names of worker nodes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.talos_workers : name => vm.name
  }
}

# Cluster configuration
output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = "https://${try(proxmox_virtual_environment_vm.talos_control_planes["talos-control-plane-1"].ipv4_addresses[1][0], "Not available yet")}:6443"
}

# Talos configuration
output "talosconfig" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.talosconfig.talos_config
  sensitive   = true
}

# Kubernetes configuration
output "kubeconfig" {
  description = "Kubernetes cluster configuration"
  value       = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive   = true
}

# Cluster information summary
output "cluster_info" {
  description = "Complete cluster information"
  value = {
    cluster_name     = "talos-cluster"
    cluster_endpoint = "https://${try(proxmox_virtual_environment_vm.talos_control_planes["talos-control-plane-1"].ipv4_addresses[1][0], "Not available yet")}:6443"
    control_planes = [
      for name, config in local.controlplane_configs : {
        name     = config.hostname
        ip       = try(proxmox_virtual_environment_vm.talos_control_planes[name].ipv4_addresses[1][0], "Not available yet")
        node     = config.node
        vm_id    = config.vm_id
      }
    ]
    workers = [
      for name, config in local.worker_configs : {
        name     = config.hostname
        ip       = try(proxmox_virtual_environment_vm.talos_workers[name].ipv4_addresses[1][0], "Not available yet")
        node     = config.node
        vm_id    = config.vm_id
      }
    ]
  }
}

# Instructions for accessing the cluster
output "access_instructions" {
  description = "Instructions for accessing the cluster"
  value = <<-EOT
    1. Save the Talos configuration:
       terraform output -raw talosconfig > talosconfig
       export TALOSCONFIG=$(pwd)/talosconfig

    2. Save the Kubernetes configuration:
       terraform output -raw kubeconfig > kubeconfig
       export KUBECONFIG=$(pwd)/kubeconfig

    3. Get the dynamic IP addresses:
       terraform output control_plane_ips
       terraform output worker_ips

    4. Check cluster status (use actual IPs from step 3):
       talosctl health --nodes <control-plane-ips>
       kubectl get nodes -o wide

    5. Access the cluster:
       kubectl cluster-info
       kubectl get pods -A
  EOT
}