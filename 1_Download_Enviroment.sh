#!/bin/bash

#Dipendenze
sudo apt-get install qemu-user-static debootstrap git kpartx

#Cartella di lavoro
cd ~
mkdir -p ~/CFS2

#Installazione chroot
sudo qemu-debootstrap --no-check-gpg --arch armhf wheezy ~/CFS2/chroot http://archive.raspbian.org/raspbian

#Montaggi FS
sudo mount -t proc proc ~/CFS2/chroot/proc
sudo mount -t sysfs sysfs ~/CFS2/chroot/sys
sudo mount -o bind /dev ~/CFS2/chroot/dev
sudo mount -o bind /dev/pts ~/CFS2/chroot/dev/pts

cd ~/CFS2

while true; do
	read -p "Clonare il firmware da zero o aggiornarlo [c/a]?\n" -n 1 -r -s
	case $REPLY in
		[c]* ) sudo rm -r firmware; git clone https://github.com/raspberrypi/firmware.git; break;;
		[a]* ) cd firmware; git fetch origin; git reset --hard origin/master; break;;
		* ) echo -e "\nPremere [c] clona oppure [a] aggiorna.";;
	esac
done
echo ""

