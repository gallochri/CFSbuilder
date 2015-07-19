#!/bin/bash

# Aggiunta repository standard
rm -r /etc/apt/sources.list
echo "deb http://archive.raspbian.org/raspbian wheezy main" >> /etc/apt/sources.list
echo "deb http://archive.raspberrypi.org/debian/ wheezy main" >> /etc/apt/sources.list
wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -
# Aggiunta repository Mate
echo "deb http://archive.raspbian.org/mate wheezy main" >> /etc/apt/sources.list

#Script per hostname generator
sh -c 'echo CFS >/etc/hostname'
sh -c 'echo 127.0.0.1	CFS >>/etc/hosts'

#echo "Hostname generator installation..."
#install -m 755 /root/sources/name_generator /usr/local/bin/
#install -m 755 /root/sources/cfs-registration /etc/init.d/
#update-rc.d cfs-registration defaults

#install -m 755 /root/sources/hostname.sh /etc/init.d/
#install -m 755 /root/sources/hostname_changed.sh /etc/init.d/
#update-rc.d hostname_changed.sh defaults 36 S .

# Copiatura configurazione eth0 con DHCP e wpa supplicant
cp -r /root/config/etc/network/interfaces /etc/network/interfaces
#sh -c 'cat > /etc/network/interfaces << EOF
#auto lo
#iface lo inet loopback
# 
#auto eth0
#iface eth0 inet dhcp
#EOF
#'

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
LANG=it_IT.UTF-8
EOF
'
# Aggiornamento archivi
apt-get update

echo "##########Installazione sistema di base##########"
apt-get install -y locales sudo openssh-server ntp patch less rsync sudo raspi-config
#apt-get install -y usbmount
echo "##########Utily############"
apt-get install -y wpasupplicant vim

echo "##############Installazione server X##############"
apt-get install -y lightdm

echo "################Installazione mate################"
apt-get install -y mate-core mate-desktop-environment

echo "##################Programmi CFS###################"

apt-get install -y chromium-browser
apt-get -y install oracle-java8-jdk geogebra
update-alternatives --set java /usr/lib/jvm/jdk-8-oracle-arm-vfp-hflt/jre/bin/java
apt-get -y install iceweasel iceweasel-l10n-it
#apt-get -y install avahi-daemon

# Aggiunta utente standard
adduser --disabled-password --gecos "" pi
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,netdev,input,spi,i2c,gpio pi

# Autologin per utente pi
update-rc.d lightdm enable 2
sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=.*/autologin-user=pi/"

# Configurazione usbmount.conf
#sed -i -e 's/""/"-fstype=vfat,flush,gid=plugdev,dmask=0007,fmask=0117"/g' /etc/usbmount/usbmount.conf

# Configurazione Locale
dpkg-reconfigure locales

# Configurazione tastiera
dpkg-reconfigure keyboard-configuration &&
printf "Reloading keymap. This may take a short while\n" &&
invoke-rc.d keyboard-setup start

# Configurazione timezone
dpkg-reconfigure tzdata

# Pulizia
apt-get clean

echo "Ora esci dal chroot digitando exit"
