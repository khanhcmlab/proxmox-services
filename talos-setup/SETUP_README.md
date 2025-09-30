# Talos Linux Setup

This directory contains the **Talos Linux** cluster configuration for Proxmox using Terraform.

## What's in this directory

This is the **modern, automated Talos cluster setup** that was previously in the root directory.

### 🚀 Features
- ✅ **Automated deployment** using `siderolabs/talos` Terraform provider
- ✅ **Dynamic IP addresses** (DHCP) for network flexibility  
- ✅ **Complete cluster bootstrap** in one `terraform apply`
- ✅ **Kubeconfig generation** included
- ✅ **6 VMs** across 3 Proxmox nodes (hp, gl552, pve)

### 📁 Files
- **`main.tf`** - Complete Talos cluster definition with both Proxmox VMs and Talos configuration
- **`providers.tf`** - Terraform providers (bpg/proxmox + siderolabs/talos)
- **`variables.tf`** - Variable definitions
- **`outputs.tf`** - Cluster outputs (IPs, configs, etc.)
- **`cloud-init.tf`** - Network configuration locals
- **`README.md`** - Main documentation for Talos setup
- **`TALOS_README.md`** - Detailed Talos Linux guide
- **`DYNAMIC_IP_SUMMARY.md`** - Dynamic IP configuration details
- **`INTERFACE_UPDATE.md`** - Interface change documentation (eth0 → ens18)

### 🏗️ Architecture
- **3 Control Planes**: talos-control-plane-1,2,3 (VM IDs 120,122,124)
- **3 Workers**: talos-worker-1,2,3 (VM IDs 121,123,125)
- **Network**: Dynamic IPs via DHCP on ens18 interface
- **Storage**: Uses `local:iso/metal-amd64.iso` for Talos installation

### 🚀 Quick Start
```bash
cd talos-setup
terraform init
terraform apply

# Get cluster access
terraform output -raw talosconfig > talosconfig
terraform output -raw kubeconfig > kubeconfig
export TALOSCONFIG=$(pwd)/talosconfig
export KUBECONFIG=$(pwd)/kubeconfig

# Use the cluster
kubectl get nodes -o wide
```

### 📋 Requirements
- Proxmox VE server with API access
- `metal-amd64.iso` uploaded to `local` storage on all nodes
- `talosctl` CLI tool installed
- Terraform installed

## Why This Setup?

This Talos configuration offers:
- 🛡️ **Immutable OS** - More secure than traditional Linux
- 🚀 **Kubernetes-native** - Built specifically for K8s
- ⚡ **Fast deployment** - Complete cluster in 5-10 minutes
- 🔄 **Easy management** - API-driven configuration
- 📦 **Minimal footprint** - ~150MB OS

## Migration Note

This setup was moved from the root directory to allow the **Arch Linux setup** to return to the root directory. Both setups are fully functional and serve different purposes:

- **Root directory**: Traditional Arch Linux VMs with manual Kubernetes setup
- **talos-setup/**: Modern Talos Linux with automated Kubernetes cluster

Choose the approach that best fits your needs!