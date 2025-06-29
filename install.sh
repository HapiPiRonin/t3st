#!/bin/bash

# Arch Install Script - KDE + Hacking Tools
# Author: ChatGPT & Ronin

# ---- CONFIG ----
DISK="/dev/sda"
ROOT_PART="${DISK}2"
EFI_PART="${DISK}1"
HOSTNAME="ARCH"
USERNAME="ronin"
PASSWORD="HapiSpidey"   # change after install!
TIMEZONE="Asia/Yangon"
LOCALE="en_US.UTF-8"

# ---- FORMAT & MOUNT ----
echo "[+] Formatting partitions..."
mkfs.fat -F32 $EFI_PART
mkfs.ext4 $ROOT_PART

echo "[+] Mounting root..."
mount $ROOT_PART /mnt
mkdir /mnt/boot
mount $EFI_PART /mnt/boot

# ---- BASE INSTALL ----
echo "[+] Installing base system..."
pacstrap /mnt base linux linux-firmware sudo nano networkmanager grub efibootmgr base-devel git vim

# ---- FSTAB ----
genfstab -U /mnt >> /mnt/etc/fstab

# ---- CHROOT SETUP ----
arch-chroot /mnt /bin/bash <<EOF

# Time & Locale
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Root password
echo "root:$PASSWORD" | chpasswd

# User
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable network
systemctl enable NetworkManager

EOF

# ---- KDE & TOOLS INSTALL ----
arch-chroot /mnt /bin/bash <<EOF
echo "[+] Installing KDE + hacking tools..."
pacman -S --noconfirm plasma-meta sddm dolphin konsole firefox ark \
  wireshark-qt nmap burpsuite sqlmap metasploit hydra john gobuster base-devel

systemctl enable sddm
EOF

# ---- DONE ----
echo "[+] Arch installation complete!"
echo "[!] Reboot after removing the USB"
