#!/bin/bash

# Dentro il chroot
sudo LC_ALL=C chroot ~/CFS2/chroot

# Aggiunta repository standard
rm -r /etc/apt/sources.list
echo "deb http://archive.raspbian.org/raspbian wheezy main" >> /etc/apt/sources.list
echo "deb http://archive.raspberrypi.org/debian/ wheezy main" >> /etc/apt/sources.list
wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -

# Aggiunta repository Mate
echo "deb http://archive.raspbian.org/mate wheezy main" >> /etc/apt/sources.list

# TODO Nome host temporaneo da sostituire con lo script che carica i nomi accazzo
sh -c 'echo cfs >/etc/hostname'	
sh -c 'echo 127.0.0.1    cfs >>/etc/hosts'

# Configurazione eth0 con DHCP
sh -c 'cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback
 
auto eth0
iface eth0 inet dhcp
EOF
'

# Configurazione fstab per SD card
sh -c 'cat > /etc/fstab << EOF
proc /proc proc defaults 0 0
/dev/mmcblk0p1 /boot vfat defaults 0 0
EOF
'

# TODO verificare la correttezza su raspbian CFS configurata col vecchio script
sh -c 'cat >> /root/.bashrc << EOF
LC_ALL=C
LANGUAGE=C
LANG=C
EOF
'
# Aggiornamento archivi
apt-get update

# Installazione sistema di base
apt-get install -y locales sudo openssh-server ntp usbmount patch less rsync sudo raspi-config

# Installazione mate
apt-get install -y mate-core mate-desktop-environment

# Aggiunta utente standard
adduser pi
usermod -a -G sudo,staff,kmem,plugdev pi

# Configurazione usbmount.conf
sed -i -e 's/""/"-fstype=vfat,flush,gid=plugdev,dmask=0007,fmask=0117"/g' /etc/usbmount/usbmount.conf

# Pulizia e uscita dal chroot
apt-get clean
exit
