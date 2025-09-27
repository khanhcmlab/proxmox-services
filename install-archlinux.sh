#!/bin/bash

# Automated Arch Linux Installation Script
# This script will be used to install Arch Linux on VMs with predefined configurations

HOSTNAME=$1
IP_ADDRESS=$2
GATEWAY=${3:-"192.168.1.1"}
DNS_SERVERS=${4:-"8.8.8.8,8.8.4.4"}

if [ -z "$HOSTNAME" ] || [ -z "$IP_ADDRESS" ]; then
    echo "Usage: $0 <hostname> <ip_address> [gateway] [dns_servers]"
    echo "Example: $0 control-plane-1 192.168.1.10 192.168.1.1 8.8.8.8,8.8.4.4"
    exit 1
fi

echo "Starting Arch Linux installation for $HOSTNAME with IP $IP_ADDRESS"

# Set up faster mirrors
echo "Setting up pacman mirrors..."
reflector --country US --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Update package database
pacman -Sy

# Partition the disk (assuming /dev/sda)
echo "Partitioning disk..."
parted /dev/sda --script mklabel gpt
parted /dev/sda --script mkpart ESP fat32 1MiB 513MiB
parted /dev/sda --script set 1 esp on
parted /dev/sda --script mkpart primary ext4 513MiB 100%

# Format partitions
echo "Formatting partitions..."
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount partitions
echo "Mounting partitions..."
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Install base system
echo "Installing base system..."
pacstrap /mnt base base-devel linux linux-firmware networkmanager openssh sudo vim git curl wget htop

# Generate fstab
echo "Generating fstab..."
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
bootctl --path=/boot install
cat > /boot/loader/loader.conf << BOOTLOADER
default arch
timeout 3
editor no
BOOTLOADER

cat > /boot/loader/entries/arch.conf << ARCHENTRY
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
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
pacman -Syu --noconfirm

echo "System installation completed for $HOSTNAME"
EOF

# Make script executable and run it
chmod +x /mnt/setup-system.sh
arch-chroot /mnt /setup-system.sh

# Clean up
rm /mnt/setup-system.sh

# Unmount and reboot
echo "Installation complete! Unmounting and preparing for reboot..."
umount -R /mnt
echo "You can now reboot the system. The VM will boot from disk with:"
echo "Hostname: $HOSTNAME"
echo "IP Address: $IP_ADDRESS"
echo "Username: arch / Password: archlinux"
echo "Root Password: archlinux"