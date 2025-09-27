#!/bin/bash

# Fully Automated Arch Linux Installation Script
# This script will completely install and configure Arch Linux without user intervention

HOSTNAME=$1
IP_ADDRESS=$2
GATEWAY=${3:-"192.168.1.1"}
DNS_SERVERS=${4:-"8.8.8.8,8.8.4.4"}

if [ -z "$HOSTNAME" ] || [ -z "$IP_ADDRESS" ]; then
    echo "Usage: $0 <hostname> <ip_address> [gateway] [dns_servers]"
    echo "Example: $0 control-plane-1 192.168.1.110 192.168.1.1 8.8.8.8,8.8.4.4"
    exit 1
fi

echo "=========================================="
echo "🚀 FULLY AUTOMATED ARCH LINUX INSTALLATION"
echo "=========================================="
echo "Hostname: $HOSTNAME"
echo "IP Address: $IP_ADDRESS"
echo "Gateway: $GATEWAY"
echo "DNS: $DNS_SERVERS"
echo "=========================================="
echo ""

# Enable non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Set up internet connection first
echo "🌐 Setting up network connection..."
ip link set $(ip link | grep -E "ens|eth" | grep -v lo | head -1 | cut -d: -f2 | tr -d ' ') up
dhcpcd &
sleep 10

# Set up faster mirrors
echo "🔍 Setting up pacman mirrors..."
pacman -Sy --noconfirm reflector
reflector --country US --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Update package database
echo "📦 Updating package database..."
pacman -Sy --noconfirm

# Auto-detect the main disk
DISK=$(lsblk -dpno NAME | grep -E "/dev/[sv]d[a-z]$" | head -1)
echo "💽 Auto-detected disk: $DISK"

# Wipe disk completely and partition
echo "🔧 Partitioning disk $DISK..."
wipefs -af $DISK
parted $DISK --script mklabel gpt
parted $DISK --script mkpart ESP fat32 1MiB 513MiB
parted $DISK --script set 1 esp on
parted $DISK --script mkpart primary ext4 513MiB 100%

# Wait for partition creation
sleep 3

# Format partitions
echo "📝 Formatting partitions..."
mkfs.fat -F32 ${DISK}1
mkfs.ext4 -F ${DISK}2

# Mount partitions
echo "📁 Mounting partitions..."
mount ${DISK}2 /mnt
mkdir -p /mnt/boot
mount ${DISK}1 /mnt/boot

# Install base system
echo "⚙️  Installing base system (this may take a while)..."
pacstrap /mnt base base-devel linux linux-firmware networkmanager openssh sudo vim git curl wget htop nano bash-completion

# Generate fstab
echo "📋 Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot and configure system
cat > /mnt/setup-system.sh << EOF
#!/bin/bash

# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << HOSTS
127.0.0.1   localhost
::1         localhost
$IP_ADDRESS $HOSTNAME.local $HOSTNAME
HOSTS

# Set root password (you should change this)
echo "root:archlinux" | chpasswd

# Create user
useradd -m -G wheel -s /bin/bash arch
echo "arch:archlinux" | chpasswd
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install and configure bootloader (systemd-boot)
echo "🥾 Installing bootloader..."
bootctl --path=/boot install
cat > /boot/loader/loader.conf << BOOTLOADER
default arch
timeout 3
editor no
BOOTLOADER

# Get the root partition UUID
ROOT_UUID=\$(blkid -s UUID -o value \${DISK}2)
cat > /boot/loader/entries/arch.conf << ARCHENTRY
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=UUID=\$ROOT_UUID rw
ARCHENTRY

# Configure network with static IP
cat > /etc/systemd/network/20-ethernet.network << NETWORK
[Match]
Name=ens*

[Network]
Address=$IP_ADDRESS/24
Gateway=$GATEWAY
DNS=$DNS_SERVERS
NETWORK

# Enable services
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Update system
echo "🔄 Updating system..."
pacman -Syu --noconfirm

# Create SSH key directory and set proper permissions
mkdir -p /home/arch/.ssh
chmod 700 /home/arch/.ssh
chown arch:arch /home/arch/.ssh

echo "✅ System installation completed for $HOSTNAME"
EOF

# Make script executable and run it
chmod +x /mnt/setup-system.sh
arch-chroot /mnt /setup-system.sh

# Clean up
rm /mnt/setup-system.sh

# Unmount and reboot
echo "🎉 Installation complete! Unmounting and preparing for reboot..."
umount -R /mnt

echo "=========================================="
echo "✅ INSTALLATION COMPLETED SUCCESSFULLY!"
echo "=========================================="
echo "Hostname: $HOSTNAME"
echo "IP Address: $IP_ADDRESS"
echo "Username: arch / Password: archlinux"
echo "Root Password: archlinux"
echo ""
echo "⚠️  IMPORTANT: Change default passwords after first login!"
echo ""
echo "🔄 Rebooting in 5 seconds..."
sleep 5
reboot