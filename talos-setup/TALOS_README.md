# Talos Linux on Proxmox with Terraform

This Terraform configuration creates six virtual machines on Proxmox nodes running Talos Linux - a modern, secure, and immutable Kubernetes-focused operating system.

## VM Specifications

| VM Name | Node | VM ID | CPU | RAM | Disk | Role | IP Address |
|---------|------|-------|-----|-----|------|------|------------|
| talos-control-plane-1 | hp | 120 | 1 core | 4GB | 50GB | Control Plane | 192.168.1.120 |
| talos-worker-1 | hp | 121 | 3 cores | 28GB | 50GB | Worker Node | 192.168.1.121 |
| talos-control-plane-2 | gl552 | 122 | 1 core | 3GB | 25GB | Control Plane | 192.168.1.122 |
| talos-worker-2 | gl552 | 123 | 3 cores | 5GB | 25GB | Worker Node | 192.168.1.123 |
| talos-control-plane-3 | pve | 124 | 1 core | 4GB | 25GB | Control Plane | 192.168.1.124 |
| talos-worker-3 | pve | 125 | 3 cores | 12GB | 25GB | Worker Node | 192.168.1.125 |

## Prerequisites

1. **Proxmox Server**: Ensure your Proxmox server is running and accessible
2. **Talos ISO**: Download and upload `metal-amd64.iso` from [Talos Releases](https://github.com/siderolabs/talos/releases) to the `local` storage on each node
3. **Storage**: Ensure `local-lvm` storage is available on all nodes (hp, gl552, pve)
4. **Terraform**: Install Terraform on your local machine
5. **talosctl**: Install the Talos CLI tool

## Quick Start

### 1. Install Required Tools

**Install Terraform:**
```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Install talosctl:**
```bash
curl -sL https://talos.dev/install | sh
```

### 2. Configure Proxmox API Token

1. Log into your Proxmox web interface
2. Go to **Datacenter** → **Permissions** → **API Tokens**
3. Create a new API token with full privileges
4. Edit `terraform.tfvars` with your credentials

### 3. Deploy the VMs

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Deploy the VMs
terraform apply
```

### 4. Configure Talos Cluster

After the VMs are created and booted from the Talos ISO:

#### Generate Talos Configuration

```bash
# Generate cluster configuration
talosctl gen config talos-cluster https://192.168.1.120:6443 --output-dir _out
```

This creates:
- `_out/controlplane.yaml` - Control plane configuration
- `_out/worker.yaml` - Worker node configuration  
- `_out/talosconfig` - Client configuration

#### Apply Configuration to Control Planes

```bash
# Apply to first control plane
talosctl apply-config --insecure --nodes 192.168.1.120 --file _out/controlplane.yaml

# Apply to second control plane
talosctl apply-config --insecure --nodes 192.168.1.122 --file _out/controlplane.yaml

# Apply to third control plane
talosctl apply-config --insecure --nodes 192.168.1.124 --file _out/controlplane.yaml
```

#### Apply Configuration to Workers

```bash
# Apply to workers
talosctl apply-config --insecure --nodes 192.168.1.121 --file _out/worker.yaml
talosctl apply-config --insecure --nodes 192.168.1.123 --file _out/worker.yaml
talosctl apply-config --insecure --nodes 192.168.1.125 --file _out/worker.yaml
```

#### Bootstrap the Cluster

```bash
# Set the talosctl configuration
export TALOSCONFIG="_out/talosconfig"

# Bootstrap the first control plane
talosctl bootstrap --nodes 192.168.1.120

# Wait for the cluster to be ready
talosctl kubeconfig --nodes 192.168.1.120
```

### 5. Access Your Kubernetes Cluster

```bash
# Get kubeconfig
talosctl kubeconfig --nodes 192.168.1.120

# Check cluster status
kubectl get nodes
kubectl get pods -A
```

## Talos Features

### Why Talos?

- **🛡️ Immutable**: Read-only root filesystem, cannot be modified at runtime
- **🔒 Secure**: Minimal attack surface, no SSH, no package manager
- **🚀 Fast**: Boots quickly, small footprint
- **🔄 Self-healing**: Automatic recovery and updates
- **📦 Container-focused**: Built specifically for Kubernetes
- **🎯 API-driven**: Managed via API, not traditional tools

### Key Benefits

1. **Security**: No shell access, immutable OS, secure by default
2. **Reliability**: Self-healing, automatic recovery
3. **Simplicity**: No manual OS management required
4. **Performance**: Optimized for Kubernetes workloads
5. **Updates**: Atomic updates with rollback capability

## Common Operations

### Check Node Status
```bash
talosctl --nodes 192.168.1.120,192.168.1.122,192.168.1.124 health
```

### View Logs
```bash
talosctl --nodes 192.168.1.120 logs
```

### Restart a Node
```bash
talosctl --nodes 192.168.1.120 reboot
```

### Upgrade Talos
```bash
talosctl --nodes 192.168.1.120 upgrade --image ghcr.io/siderolabs/installer:v1.5.5
```

### Get Node Configuration
```bash
talosctl --nodes 192.168.1.120 get machineconfig
```

## Network Configuration

- **Subnet**: 192.168.1.0/24
- **Gateway**: 192.168.1.1
- **DNS**: 8.8.8.8, 8.8.4.4
- **Static IPs**: 192.168.1.120-125

## Troubleshooting

### Common Issues

1. **VM won't boot**: Ensure Talos ISO is properly uploaded to Proxmox
2. **Network issues**: Check static IP configuration and gateway
3. **Cluster won't form**: Verify all control planes can communicate
4. **Certificate errors**: Regenerate configs with correct IPs

### Useful Commands

```bash
# Check Talos version
talosctl --nodes 192.168.1.120 version

# View system information
talosctl --nodes 192.168.1.120 dashboard

# Check cluster membership
talosctl --nodes 192.168.1.120 get members

# View network configuration
talosctl --nodes 192.168.1.120 get addresses
```

## File Structure

```
.
├── README.md                    # This file
├── providers.tf                 # Terraform and provider configuration
├── variables.tf                 # Variable definitions
├── main.tf                      # Complete Talos cluster definition
├── outputs.tf                   # Cluster outputs (IPs, configs, etc.)
├── cloud-init.tf                # Network configuration locals
├── terraform.tfvars.example     # Example variables file
├── .gitignore                   # Git ignore rules
└── arch-setup/                  # Previous Arch Linux setup
    ├── README.md
    ├── main.tf
    ├── install-archlinux.sh
    ├── auto-install.sh
    └── ... (all previous Arch files)
```

## Comparison: Talos vs Arch Linux

| Feature | Talos Linux | Arch Linux |
|---------|-------------|------------|
| **Security** | Immutable, no shell access | Traditional Linux, full access |
| **Updates** | Atomic, rollback capable | Package-based updates |
| **Management** | API-driven | SSH/manual management |
| **Kubernetes** | Built-in, optimized | Manual installation required |
| **Maintenance** | Self-healing, minimal | Regular maintenance needed |
| **Boot Time** | Very fast (~30s) | Standard (~60-120s) |
| **Disk Usage** | Minimal (~150MB) | Full OS (~2-5GB) |

## Next Steps

1. **Deploy applications** to your Kubernetes cluster
2. **Set up monitoring** with Prometheus/Grafana
3. **Configure ingress** for external access
4. **Implement GitOps** with ArgoCD or Flux
5. **Set up persistent storage** with Longhorn or Rook

Your Talos Linux cluster is now ready for production Kubernetes workloads! 🚀