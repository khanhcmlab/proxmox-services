# Proxmox Services with Terraform

This Terraform configuration creates two virtual machines on a Proxmox node using the Arch Linux ISO image. It uses the modern `bpg/proxmox` provider which offers better resource management and active development.

## VM Specifications

### VM 1 (archlinux-small)
- **VM ID**: 100
- **CPU**: 1 core
- **RAM**: 4GB
- **Disk**: 50GB (storage: local-lvm)
- **Node**: hp
- **ISO**: archlinux-2025.08.01-x86_64.iso (from local storage)

### VM 2 (archlinux-large)
- **VM ID**: 101
- **CPU**: 3 cores
- **RAM**: 28GB
- **Disk**: 50GB (storage: local-lvm)
- **Node**: hp
- **ISO**: archlinux-2025.08.01-x86_64.iso (from local storage)

## Prerequisites

1. **Proxmox Server**: Ensure your Proxmox server is running and accessible
2. **ISO Image**: Make sure `archlinux-2025.08.01-x86_64.iso` is uploaded to the `local` storage on the `hp` node
3. **Storage**: Ensure `local-lvm` storage is available on the `hp` node
4. **Terraform**: Install Terraform on your local machine

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

## Post-Deployment: Installing Arch Linux

After the VMs are created, you need to install Arch Linux on each VM. See the detailed guide:

📖 **[Arch Linux Installation Guide](ARCH_INSTALLATION_GUIDE.md)**

The guide includes:
- Automated installation script
- Manual installation steps
- Network configuration with static IPs
- Post-installation security recommendations

### Quick Installation

Use the provided automation script:

```bash
# After booting each VM from the Arch ISO
curl -O https://raw.githubusercontent.com/khanhcmlab/proxmox-services/main/install-archlinux.sh
chmod +x install-archlinux.sh

# Run for each VM with appropriate hostname and IP
./install-archlinux.sh control-plane-1 192.168.1.110
./install-archlinux.sh worker-1 192.168.1.111
# ... etc for all VMs
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

## File Structure

```
.
├── README.md                    # This file
├── ARCH_INSTALLATION_GUIDE.md   # Detailed Arch Linux installation guide
├── providers.tf                 # Terraform and provider configuration
├── variables.tf                 # Variable definitions
├── main.tf                      # VM resource definitions
├── outputs.tf                   # Output definitions
├── cloud-init.tf                # Network configuration locals
├── install-archlinux.sh         # Automated installation script
├── terraform.tfvars.example     # Example variables file
└── .gitignore                   # Git ignore rules
```
