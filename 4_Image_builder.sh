#!/bin/bash

OS_NAME=`lsb_release -i -s`
case $OS_NAME in 
  Debian | Ubuntu) sudo rm ~/CFS2/chroot/usr/bin/qemu-arm-static;;
  "openSUSE project") sudo rm ~/CFS2/chroot/usr/bin/qemu-arm-binfmt; sudo rm ~/CFS2/chroot/usr/bin/qemu-arm;;
esac

#Smontaggio dispositivi
sudo umount --force ~/CFS2/chroot/proc
sudo umount --force ~/CFS2/chroot/sys
sudo umount --force ~/CFS2/chroot/dev/pts
sudo umount --force ~/CFS2/chroot/dev

#Reboot in caso di device busy

echo "Creazione file per immagine"
cd ~/CFS2
dd if=/dev/zero of=CFS2.img bs=1MB count=5120

# Montaggio immagine in loop device
sudo losetup -f --show CFS2.img

sudo fdisk /dev/loop0 << EOF
n
p
1
 
+64M
t
c
n
p
2
 
 
w
EOF

sudo losetup -d /dev/loop0

sudo kpartx -va CFS2.img | sed -E 's/.*(loop[0-9])p.*/1/g' | head -1

# Formattazione
sudo mkfs.vfat /dev/mapper/loop0p1
sudo mkfs.ext4 /dev/mapper/loop0p2

# Copiatura rootfs e bootfs
sudo rm -rf /mnt/bootfs
sudo rm -rf /mnt/rootfs
sudo mkdir /mnt/bootfs
sudo mkdir /mnt/rootfs

sudo mount /dev/mapper/loop0p1 /mnt/bootfs
sudo mount /dev/mapper/loop0p2 /mnt/rootfs

sudo cp -R bootfs/* /mnt/bootfs
sudo rsync -a chroot/ /mnt/rootfs
sudo cp -a firmware/hardfp/opt/vc /mnt/rootfs/opt/
sudo umount /mnt/rootfs

# TODO queste sono assimilabili a personalizzazione e si potrebbero
# spostare nel file Personalize.sh

# Creazione config.txt
sudo sh -c 'cat >/mnt/bootfs/config.txt<<EOF
kernel=kernel.img
arm_freq=800
core_freq=250
sdram_freq=400
over_voltage=0
gpu_mem=16
EOF
'

# TODO queste sono assimilabili a personalizzazione e si potrebbero
# spostare nel file Personalize.sh

# Creazione cmdline.txt
sudo sh -c 'cat >/mnt/bootfs/cmdline.txt<<EOF
dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait
EOF
'

sudo umount /mnt/bootfs

# Rimozione mappature
sudo kpartx -d CFS2.img


# Per installare l'immagine:
# sudo dd if=CFS2.img of=/dex/sdX bs=4M 



