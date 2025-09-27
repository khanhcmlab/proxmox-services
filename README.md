# Talos Linux on Proxmox with Terraform

This 3. **talosctl**: Install the Talos CLI tool: `curl -sL https://talos.dev/install | sh` (optional, for cluster management)erraform configuration creates six virtual machines on Proxmox nodes running **Talos Linux** - a modern, secure, and immutable Kubernetes-focused operating system. 

🚀 **Uses the official `siderolabs/talos` Terraform provider for automated configuration!**

✨ **Features:**
- ✅ **Dynamic IP addresses** (DHCP) for flexibility
- ✅ **Complete cluster bootstrap** in one `terraform apply`
- ✅ **Kubeconfig generation** included
- ✅ **No manual configuration** required

🚀 **[Full Talos Documentation](TALOS_README.md)**

For the previous Arch Linux setup, see the `arch-setup/` directory.

## VM Specifications

| VM Name | Node | VM ID | CPU | RAM | Disk | Role | IP Address |
|---------|------|-------|-----|-----|------|------|------------|
| talos-control-plane-1 | hp | 120 | 1 core | 4GB | 50GB | Control Plane | DHCP |
| talos-worker-1 | hp | 121 | 3 cores | 28GB | 50GB | Worker Node | DHCP |
| talos-control-plane-2 | gl552 | 122 | 1 core | 3GB | 25GB | Control Plane | DHCP |
| talos-worker-2 | gl552 | 123 | 3 cores | 5GB | 25GB | Worker Node | DHCP |
| talos-control-plane-3 | pve | 124 | 1 core | 4GB | 25GB | Control Plane | DHCP |
| talos-worker-3 | pve | 125 | 3 cores | 12GB | 25GB | Worker Node | DHCP |

**ISO Required**: `metal-amd64.iso` (Talos Linux)

## ✨ Automated Configuration with Talos Provider

**New**: This configuration uses the official `siderolabs/talos` Terraform provider to automatically:
- 🌐 Configure dynamic IP addresses (DHCP) for network flexibility
- 🔧 Generate machine configurations
- 🚀 Bootstrap the Kubernetes cluster
- 📝 Generate kubeconfig and talosconfig

**No manual configuration required!** Just run `terraform apply` and get a complete cluster.

## Prerequisites

1. **Proxmox Server**: Ensure your Proxmox server is running and accessible
2. **Talos ISO**: Download and upload `metal-amd64.iso` from [Talos Releases](https://github.com/siderolabs/talos/releases) to the `local` storage on all nodes
3. **Storage**: Ensure `local-lvm` storage is available on all nodes (hp, gl552, pve)
4. **Terraform**: Install Terraform on your local machine
5. **talosctl**: Install the Talos CLI tool: `curl -sL https://talos.dev/install | sh`

## Terraform Providers

This configuration uses two modern, actively maintained providers:

### **bpg/proxmox** Provider
- Better resource management than telmate/proxmox
- Active development and maintenance
- More comprehensive API coverage
- Better error handling

### **siderolabs/talos** Provider  
- Official Talos provider from Sidero Labs
- Automated machine configuration
- Cluster bootstrapping
- Kubeconfig generation

Both providers work together to create a fully automated Talos cluster deployment.

## Setup Instructions

### 1. Install Terraform

**macOS (using Homebrew):**
```bash
brew install terraform
```

**Linux:**
```bash
# Download and install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### 2. Create API Token in Proxmox

1. Log into your Proxmox web interface
2. Go to **Datacenter** → **Permissions** → **API Tokens**
3. Click **Add** to create a new API token:
   - **User**: Select or create a user (e.g., `terraform@pve`)
   - **Token ID**: Give it a name (e.g., `mytoken`)
   - **Privilege Separation**: Uncheck this for full user permissions
4. Click **Add** and **copy the token secret** (you won't see it again!)

### 3. Configure Variables

1. The `terraform.tfvars` file is already created for you
2. Edit `terraform.tfvars` with your Proxmox API token credentials:
   ```hcl
   proxmox_api_url      = "https://your-proxmox-server:8006/api2/json"
   proxmox_user         = "terraform@pve!mytoken"  # Format: username@realm!token_id
   proxmox_password     = "your-api-token-secret-here"
   proxmox_tls_insecure = true
   ```

   **Important**: Replace:
   - `your-proxmox-server` with your actual Proxmox server IP/hostname
   - `terraform@pve!mytoken` with your actual `username@realm!token_id`
   - `your-api-token-secret-here` with the actual token secret you copied

### 4. Deploy the Complete Cluster

1. Initialize Terraform (install providers):
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan
   ```

3. Deploy everything in one command:
   ```bash
   terraform apply
   ```

4. Confirm the deployment by typing `yes` when prompted.

**That's it!** Terraform will:
- Create all 6 VMs on Proxmox
- Configure static IP addresses
- Install and configure Talos Linux
- Bootstrap the Kubernetes cluster
- Generate configuration files

### 5. Access Your Cluster

After deployment completes (usually 5-10 minutes):

```bash
# Save the cluster configurations
terraform output -raw talosconfig > talosconfig
terraform output -raw kubeconfig > kubeconfig

# Set environment variables
export TALOSCONFIG=$(pwd)/talosconfig
export KUBECONFIG=$(pwd)/kubeconfig

# Get the dynamic IP addresses
terraform output control_plane_ips
terraform output worker_ips

# Check cluster status
kubectl get nodes -o wide
kubectl get pods -A
```

## Configuration Details

### Network Configuration
- Both VMs are connected to the `vmbr0` bridge
- Network interface uses VirtIO for better performance

### Storage Configuration
- Boot disk: 50GB on `local-lvm` storage
- ISO mounted from `local` storage
- Uses VirtIO SCSI controller for better performance

### Boot Configuration
- VMs boot from SCSI disk first, then IDE (CD-ROM)
- ISO image is mounted as IDE device

## Managing the Infrastructure

### View Outputs
```bash
terraform output
```

### Update Configuration
1. Modify the `.tf` files as needed
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes

### Destroy Infrastructure
```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Verify your Proxmox API token in `terraform.tfvars`
2. **Storage Not Found**: Ensure `local` and `local-lvm` storages exist on the `hp` node
3. **Node Not Found**: Verify the `hp` node exists and is online
4. **ISO Not Found**: Ensure `archlinux-2025.08.01-x86_64.iso` is uploaded to `local` storage
5. **Provider Migration**: If upgrading from telmate/proxmox, run `terraform init -upgrade` after changing providers

### Useful Commands

Check Proxmox storage:
```bash
# On Proxmox server
pvesm status
```

List ISO images:
```bash
# On Proxmox server
ls /var/lib/vz/template/iso/
```

## Security Notes

- The `terraform.tfvars` file contains sensitive information and is excluded from version control
- Consider using environment variables or Terraform Cloud for production deployments
- Review and adjust security groups and firewall rules as needed

## Cluster Information

The Terraform configuration automatically creates:

### Control Plane Nodes
- **talos-control-plane-1**: DHCP IP (hp node, 4GB RAM, 1 CPU)
- **talos-control-plane-2**: DHCP IP (gl552 node, 3GB RAM, 1 CPU)  
- **talos-control-plane-3**: DHCP IP (pve node, 4GB RAM, 1 CPU)

### Worker Nodes
- **talos-worker-1**: DHCP IP (hp node, 28GB RAM, 3 CPU)
- **talos-worker-2**: DHCP IP (gl552 node, 5GB RAM, 3 CPU)
- **talos-worker-3**: DHCP IP (pve node, 12GB RAM, 3 CPU)

### Network Configuration
- **IP Assignment**: DHCP (dynamic)
- **DNS**: 8.8.8.8, 8.8.4.4
- **Cluster Endpoint**: Dynamic (based on first control plane's IP)

## Advanced Management

### View cluster information
```bash
terraform output cluster_info
```

### Get dynamic IP addresses
```bash
terraform output control_plane_ips
terraform output worker_ips
```

### Check cluster health (use actual IPs from above)
```bash
talosctl health --nodes <control-plane-ip-1>,<control-plane-ip-2>,<control-plane-ip-3>
```

### Access Talos dashboard (use actual first control plane IP)
```bash
talosctl dashboard --nodes <first-control-plane-ip>
```

## Why Talos Linux?

- 🛡️ **Immutable & Secure**: Read-only OS, no SSH access
- 🚀 **Kubernetes-Native**: Built specifically for K8s
- 🔄 **Self-Healing**: Automatic recovery and updates
- ⚡ **Fast Boot**: ~30 second boot time
- 📦 **Minimal**: ~150MB footprint
- 🎯 **API-Driven**: Managed via API, not traditional tools

## File Structure

```
.
├── README.md                    # This file (Talos setup with provider)
├── TALOS_README.md              # Detailed Talos Linux guide
├── providers.tf                 # Terraform providers (proxmox + talos)
├── variables.tf                 # Variable definitions
├── main.tf                      # ⭐ Complete Talos cluster definition
├── outputs.tf                   # Cluster outputs (IPs, configs, etc.)
├── cloud-init.tf                # Network configuration locals
├── terraform.tfvars.example     # Example variables file
├── .gitignore                   # Git ignore rules
└── arch-setup/                  # Previous Arch Linux setup
    ├── README.md
    ├── ARCH_INSTALLATION_GUIDE.md
    ├── main.tf
    ├── install-archlinux.sh
    ├── auto-install.sh
    ├── batch-install.sh
    └── ... (all previous files)
```

**Clean and Simple:**
- ⭐ `main.tf` includes complete Talos cluster automation
- 🔧 Uses `siderolabs/talos` provider for automated configuration  
- 📝 Configuration files generated automatically via Terraform outputs
- 🧼 No legacy scripts or manual processes needed
