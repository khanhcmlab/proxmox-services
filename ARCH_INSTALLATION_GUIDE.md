# Arch Linux Installation Guide for Proxmox VMs

## VM Network Configuration

All VMs are configured with static IP addresses in the 192.168.1.0/24 network:

| VM Name | Node | VM ID | IP Address | CPU | RAM | Disk | Role |
|---------|------|-------|------------|-----|-----|------|------|
| control-plane-1 | hp | 110 | 192.168.1.110 | 1 core | 4GB | 50GB | Control Plane |
| worker-1 | hp | 111 | 192.168.1.111 | 3 cores | 28GB | 50GB | Worker Node |
| control-plane-2 | gl552 | 112 | 192.168.1.112 | 1 core | 3GB | 25GB | Control Plane |
| worker-2 | gl552 | 113 | 192.168.1.113 | 3 cores | 5GB | 25GB | Worker Node |
| control-plane-3 | pve | 114 | 192.168.1.114 | 1 core | 4GB | 25GB | Control Plane |
| worker-3 | pve | 115 | 192.168.1.115 | 3 cores | 12GB | 25GB | Worker Node |

## Network Settings

- **Gateway**: 192.168.1.1
- **DNS Servers**: 8.8.8.8, 8.8.4.4
- **Subnet**: 192.168.1.0/24

## Installation Methods

### Method 1: Automated Installation Script

Use the provided `install-archlinux.sh` script for automated installation:

#### For each VM:

1. **Boot from Arch Linux ISO**
2. **Download and run the installation script**:

```bash
# Control Plane 1
curl -O https://raw.githubusercontent.com/your-repo/proxmox-services/main/install-archlinux.sh
chmod +x install-archlinux.sh
./install-archlinux.sh control-plane-1 192.168.1.110

# Worker 1
./install-archlinux.sh worker-1 192.168.1.111

# Control Plane 2
./install-archlinux.sh control-plane-2 192.168.1.112

# Worker 2
./install-archlinux.sh worker-2 192.168.1.113

# Control Plane 3
./install-archlinux.sh control-plane-3 192.168.1.114

# Worker 3
./install-archlinux.sh worker-3 192.168.1.115
```

### Method 2: Manual Installation

If you prefer manual installation, follow these steps for each VM:

#### 1. Boot from Arch Linux ISO and set up network

```bash
# Set up network (if needed)
ip link set ens18 up
ip addr add 192.168.1.110/24 dev ens18  # Use appropriate IP for each VM
ip route add default via 192.168.1.1
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

#### 2. Partition and format disk

```bash
# Partition disk
parted /dev/sda --script mklabel gpt
parted /dev/sda --script mkpart ESP fat32 1MiB 513MiB
parted /dev/sda --script set 1 esp on
parted /dev/sda --script mkpart primary ext4 513MiB 100%

# Format partitions
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount partitions
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

#### 3. Install base system

```bash
# Update mirrors
reflector --country US --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Install base system
pacstrap /mnt base base-devel linux linux-firmware networkmanager openssh sudo vim git curl wget htop

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
```

#### 4. Configure system (run in chroot)

```bash
arch-chroot /mnt

# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname (example for control-plane-1)
echo "control-plane-1" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
192.168.1.110 control-plane-1.local control-plane-1
EOF

# Set passwords
echo "root:archlinux" | chpasswd
useradd -m -G wheel -s /bin/bash arch
echo "arch:archlinux" | chpasswd
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

#### 5. Install bootloader

```bash
# Install systemd-boot
bootctl --path=/boot install

# Configure bootloader
cat > /boot/loader/loader.conf << EOF
default arch
timeout 3
editor no
EOF

cat > /boot/loader/entries/arch.conf << EOF
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
EOF
```

#### 6. Configure network

```bash
# Static network configuration
cat > /etc/systemd/network/20-ethernet.network << EOF
[Match]
Name=ens*

[Network]
Address=192.168.1.110/24  # Use appropriate IP for each VM
Gateway=192.168.1.1
DNS=8.8.8.8
DNS=8.8.4.4
EOF

# Enable services
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable systemd-networkd
systemctl enable systemd-resolved
```

#### 7. Finish installation

```bash
# Exit chroot
exit

# Unmount and reboot
umount -R /mnt
reboot
```

## Post-Installation

### Default Credentials

- **Username**: `arch`
- **Password**: `archlinux`
- **Root Password**: `archlinux`

**Important**: Change these default passwords immediately after installation!

### SSH Access

SSH is enabled by default. You can access VMs using:

```bash
ssh arch@192.168.1.110  # control-plane-1
ssh arch@192.168.1.111  # worker-1
ssh arch@192.168.1.112  # control-plane-2
ssh arch@192.168.1.113  # worker-2
ssh arch@192.168.1.114  # control-plane-3
ssh arch@192.168.1.115  # worker-3
```

### Next Steps

1. **Change default passwords**
2. **Configure SSH keys for passwordless access**
3. **Install additional packages as needed**
4. **Set up Kubernetes cluster (if that's the intended use)**

## Security Recommendations

1. **Change default passwords immediately**
2. **Set up SSH key authentication**
3. **Disable password authentication in SSH**
4. **Configure firewall rules**
5. **Regular system updates**

## Troubleshooting

### Network Issues

If static IP is not working:

```bash
# Check network interface name
ip link show

# Restart networking
systemctl restart systemd-networkd
systemctl restart NetworkManager

# Check status
systemctl status systemd-networkd
ip addr show
```

### Boot Issues

If system doesn't boot:

1. Boot from Arch ISO
2. Mount the installed system
3. Check bootloader configuration
4. Reinstall bootloader if needed

### SSH Issues

If SSH is not working:

```bash
# Check SSH service
systemctl status sshd
systemctl restart sshd

# Check firewall (if enabled)
ufw status
iptables -L
```