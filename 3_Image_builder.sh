#!/bin/bash

OS_NAME=`lsb_release -i -s`
IMG_REV=`date +%Y-%m-%d_%k%M`
CURRENT_DIR=`pwd`

sudo rm -r ~/CFS2/chroot/root/2_Personalize_script_inside_chroot.sh
sudo rm -r ~/CFS2/chroot/root/sources/
sudo rm -r ~/CFS2/chroot/root/config/

case $OS_NAME in 
  Debian | Ubuntu) sudo rm ~/CFS2/chroot/usr/bin/qemu-arm-static;;
  "openSUSE project") sudo rm ~/CFS2/chroot/usr/bin/qemu-arm-binfmt; sudo rm ~/CFS2/chroot/usr/bin/qemu-arm;;
esac

#Smontaggio dispositivi
sudo umount --force ~/CFS2/chroot/proc
sudo umount --force ~/CFS2/chroot/sys
sudo umount --force ~/CFS2/chroot/dev/pts
#TODO aggiungere un if: se --force scazza usare --lazy
sudo umount --lazy ~/CFS2/chroot/dev
sudo umount --force ~/CFS2/chroot/dev

#Reboot in caso di device busy

echo "#####Creazione file per immagine######"
cd ~/CFS2
dd if=/dev/zero of=CFS_${IMG_REV}.img bs=1MB count=5120

echo "#####Montaggio immagine in loop device ######"
sudo losetup -f --show CFS_${IMG_REV}.img

echo "#####Creazione partizioni loop device#####"
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

sudo kpartx -va CFS_${IMG_REV}.img | sed -E 's/.*(loop[0-9])p.*/1/g' | head -1

sleep 2

echo "#####Formattazione#####"
sudo mkfs.vfat /dev/mapper/loop0p1
sudo mkfs.ext4 /dev/mapper/loop0p2

echo "#####Copiatura rootfs#####"
sudo rm -rf /mnt/rootfs
sudo mkdir /mnt/rootfs
sudo mount /dev/mapper/loop0p2 /mnt/rootfs
sudo rsync -a chroot/ /mnt/rootfs
sudo cp -a firmware/hardfp/opt/vc /mnt/rootfs/opt/
sudo umount /mnt/rootfs

echo "#####Copiatura bootfs#####"
sudo rm -rf /mnt/bootfs
sudo mkdir /mnt/bootfs
sudo mount /dev/mapper/loop0p1 /mnt/bootfs
sudo cp -R firmware/boot/* /mnt/bootfs

echo "#####Copiatura config.txt#####"
sudo cp ${CURRENT_DIR}/config/boot/config.txt /mnt/bootfs/config.txt
#sudo sh -c 'cat >/mnt/bootfs/config.txt<<EOF
#kernel=kernel.img
#arm_freq=800
#core_freq=250
#sdram_freq=400
#over_voltage=0
#gpu_mem=16
#EOF
#'

echo "#####Copiatura cmdline.txt######"
sudo cp ${CURRENT_DIR}/config/boot/cmdline.txt /mnt/bootfs/cmdline.txt 
#sudo sh -c 'cat >/mnt/bootfs/cmdline.txt<<EOF
#dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait
#EOF
#'

sudo umount /mnt/bootfs

echo "######Rimozione mappature######"
sudo kpartx -d CFS_${IMG_REV}.img

echo "Per installare l'immagine:"
echo "sudo dd CFS_${IMG_REV}.img of=/dex/sdX bs=4M"
exit 



