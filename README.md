# Proxmox Services with Terraform

This Terraform configuration creates six virtual machines on Proxmox nodes using **Ubuntu 24.04 LTS** cloud image. It uses the modern `bpg/proxmox` provider which offers better resource management and active development.

🚀 **For Talos Linux (automated Kubernetes cluster)**, see the [`talos-setup/`](talos-setup/) directory.

## VM Specifications

| VM Name | Node | VM ID | CPU | RAM | Disk | Role | IP Address |
|---------|------|-------|-----|-----|------|------|------------|
| control-plane-1 | hp | 110 | 1 core | 4GB | 50GB | Control Plane | 192.168.1.110 |
| worker-1 | hp | 111 | 3 cores | 28GB | 50GB | Worker Node | 192.168.1.111 |
| control-plane-2 | gl552 | 112 | 1 core | 3GB | 25GB | Control Plane | 192.168.1.112 |
| worker-2 | gl552 | 113 | 3 cores | 5GB | 25GB | Worker Node | 192.168.1.113 |
| control-plane-3 | pve | 114 | 1 core | 4GB | 25GB | Control Plane | 192.168.1.114 |
| worker-3 | pve | 115 | 3 cores | 12GB | 25GB | Worker Node | 192.168.1.115 |

**OS**: Ubuntu 24.04 LTS (minimal cloud image)

## Prerequisites

1. **Proxmox Server**: Ensure your Proxmox server is running and accessible
2. **Ubuntu Cloud Image**: Download Ubuntu 24.04 LTS cloud image to `local` storage on all nodes (hp, gl552, pve)
3. **Storage**: Ensure `local-lvm` storage is available on all nodes
4. **Terraform**: Install Terraform on your local machine

### Download Ubuntu Cloud Image

On each Proxmox node, download the Ubuntu 24.04 cloud image:
```bash
cd /var/lib/vz/template/iso/
wget https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img
```

## Provider Migration

This configuration uses the **bpg/proxmox** provider instead of the older telmate/proxmox provider. The bpg provider offers:
- Better resource management
- Active development and maintenance
- More comprehensive API coverage
- Better error handling

If you're migrating from telmate/proxmox, you'll need to:
1. Update your configuration (already done in this project)
2. Run `terraform init -upgrade` to download the new provider
3. Consider recreating resources if there are state incompatibilities

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

### 4. Deploy the Infrastructure

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Confirm the deployment by typing `yes` when prompted.

### 5. Access Your VMs

After deployment, you can:
- Access the VMs through the Proxmox web interface
- Use the VM console to install Arch Linux
- The VMs will be configured to boot from the ISO image initially

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
3. **Node Not Found**: Verify all nodes (hp, gl552, pve) exist and are online
4. **Image Not Found**: Ensure `ubuntu-24.04-minimal-cloudimg-amd64.img` is available in `local` storage on all nodes
5. **Provider Migration**: If upgrading from telmate/proxmox, run `terraform init -upgrade` after changing providers

### Useful Commands

Check Proxmox storage:
```bash
# On Proxmox server
pvesm status
```

List available images:
```bash
# On Proxmox server
ls /var/lib/vz/template/iso/
```

## Security Notes

- The `terraform.tfvars` file contains sensitive information and is excluded from version control
- Consider using environment variables or Terraform Cloud for production deployments
- Review and adjust security groups and firewall rules as needed

## Post-Deployment: Ready to Use!

After deployment, your Ubuntu VMs are **automatically configured and ready to use**:

### ✅ What's Already Configured
- **Ubuntu 24.04 LTS**: Minimal cloud image pre-installed
- **Static IP addresses**: As specified in the configuration
- **SSH access**: Ready with `ubuntu` user
- **Essential packages**: curl, wget, git, htop, net-tools installed
- **QEMU Guest Agent**: Enabled for better Proxmox integration

### 🔑 Default Credentials
- **Username**: `ubuntu`
- **Password**: `ubuntu`
- **SSH**: Enabled and ready

### 🌐 Access Your VMs

Connect to any VM using SSH:
```bash
# Connect to each VM
ssh ubuntu@192.168.1.110  # control-plane-1
ssh ubuntu@192.168.1.111  # worker-1
ssh ubuntu@192.168.1.112  # control-plane-2
ssh ubuntu@192.168.1.113  # worker-2
ssh ubuntu@192.168.1.114  # control-plane-3
ssh ubuntu@192.168.1.115  # worker-3
```

### 📋 Get VM Information
```bash
# View all VM details
terraform output vm_summary

# Get IP addresses
terraform output vm_ips

# Get SSH commands
terraform output ssh_connections
```

## Static IP Configuration

| VM Name | IP Address | Role |
|---------|------------|------|
| control-plane-1 | 192.168.1.110 | Control Plane |
| worker-1 | 192.168.1.111 | Worker Node |
| control-plane-2 | 192.168.1.112 | Control Plane |
| worker-2 | 192.168.1.113 | Worker Node |
| control-plane-3 | 192.168.1.114 | Control Plane |
| worker-3 | 192.168.1.115 | Worker Node |

## Next Steps

Your Ubuntu VMs are ready for:
- **Kubernetes cluster setup** (kubeadm, k3s, etc.)
- **Container workloads** (Docker, Podman)
- **Development environments**
- **Testing and experimentation**

## File Structure

```
.
├── README.md                    # This file
├── providers.tf                 # Terraform and provider configuration
├── variables.tf                 # Variable definitions
├── main.tf                      # Ubuntu VM definitions with cloud-init
├── outputs.tf                   # VM information outputs
├── cloud-init.tf                # Network configuration locals
├── terraform.tfvars.example     # Example variables file
├── .gitignore                   # Git ignore rules
└── talos-setup/                 # Alternative Talos Linux setup
    └── ... (Talos configuration files)
```
