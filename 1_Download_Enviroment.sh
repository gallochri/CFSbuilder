#!/bin/bash

#Dipendenze
sudo apt-get install qemu-user-static debootstrap git kpartx

#Cartella di lavoro
cd ~
mkdir ~/CFS2

#Installazione chroot
sudo qemu-debootstrap --no-check-gpg --arch armhf wheezy ~/CFS2/chroot http://archive.raspbian.org/raspbian

#Montaggi FS
sudo mount -t proc proc ~/CFS2/chroot/proc
sudo mount -t sysfs sysfs ~/CFS2/chroot/sys
sudo mount -o bind /dev ~/CFS2/chroot/dev
sudo mount -o bind /dev/pts ~/CFS2/chroot/dev/pts


#Download kernel e firmware
cd ~/CFS2
git clone https://github.com/raspberrypi/firmware.git

