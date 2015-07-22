#!/bin/bash

# Aggiunta repository standard
rm -r /etc/apt/sources.list
echo "deb http://archive.raspbian.org/raspbian wheezy main non-free" >> /etc/apt/sources.list
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
apt-get install -y locales sudo openssh-server ntp patch less rsync sudo raspi-config usbmount

echo "##########Creazione utente pi##########"
adduser --gecos "" pi

echo "##########Installazione pacchetti base##########"
apt-get install -y bash-completion blt build-essential
apt-get install -y cgroup-bin curl
apt-get install -y debconf-utils debian-reference-common debian-reference-it dhcpcd5 dphys-swapfile
apt-get install -y ed esound-common
apt-get install -y fake-hwclock fbset fonts-freefont-ttf fonts-roboto
apt-get install -y gdb gdbserver gettext-base gir1.2-glib-2.0 git git-core git-man gksu gnome-icon-theme-symbolic gvfs-backends gvfs-fuse
apt-get install -y hardlink
apt-get install -y idle idle-python2.7 idle-python3.2 idle3 python-tk ifplugd i2c-tools
apt-get install -y jackd jackd2 
apt-get install -y manpages-dev mawk menu menu-xdg
apt-get install -y ncdu nfs-common nuscratch                                         
apt-get install -y omxplayer openresolv openssl oracle-java8-jdk
apt-get install -y pkg-config poppler-data poppler-utils pypy-setuptools pypy-upstream pypy-upstream-dev pypy-upstream-doc python-numpy 
apt-get install -y python-picamera python-pifacecommon python-pifacedigitalio python-pygame python-rpi.gpio python-serial python3-numpy 
apt-get install -y python3-picamera python3-pifacecommon python3-pifacedigital-scratch-handler python3-pifacedigitalio python3-pygame python3-rpi.gpio python3-serial 
apt-get install -y raspberrypi-artwork rpi-update
apt-get install -y smartsim sonic-pi ssh strace supercollider supercollider-common supercollider-server
apt-get install -y timidity timidity-daemon
apt-get install -y usbutils
apt-get install -y v4l-utils vim
apt-get install -y wireless-tools wpagui wpasupplicant
apt-get install -y xserver-xorg-video-fbturbo x2x xinit xserver-xorg-video-fbdev

echo "##########Installazione pacchetti non-free##########"
apt-get install -y firmware-atheros firmware-libertas firmware-ralink firmware-realtek

#disponibile per Jessie
#apt-get install -y weston

echo "################Installazione mate################"
apt-get install -y mate-core mate-desktop-environment

echo "###########Installazione Desktop Manager###########"
apt-get install -y lightdm

echo "##################Programmi CFS###################"
apt-get -y install chromium-browser
apt-get -y install geogebra
update-alternatives --set java /usr/lib/jvm/jdk-8-oracle-arm-vfp-hflt/jre/bin/java
apt-get -y install iceweasel iceweasel-l10n-it
apt-get -y install -y avahi-daemon cifs-utils

# Aggiunta dell'utente Pi ai gruppi
groupadd -g 999 input
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,netdev,spi,gpio,i2c,input pi

# Autologin per utente pi
update-rc.d lightdm enable 2
sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=.*/autologin-user=pi/"
sed /etc/lightdm/lightdm.conf -i -e "s/^# user-session =.*/user-session=mate-session/"
sed /etc/lightdm/lightdm.conf -i -e "s/^#user-session=.*/user-session=mate-session/"
cp -r /root/config/home/pi/xinitrc	/home/pi/.xinitrc
update-alternatives --set x-session-manager /usr/bin/mate-session

# Configurazione usbmount.conf
sed -i -e 's/""/"-fstype=vfat,flush,gid=plugdev,dmask=0007,fmask=0117"/g' /etc/usbmount/usbmount.conf

# Configurazione Locale
# installare anche en_GB.UTF-8
dpkg-reconfigure locales

# Configurazione tastiera
dpkg-reconfigure keyboard-configuration &&
printf "Reloading keymap. This may take a short while\n" &&
invoke-rc.d keyboard-setup start

# Configurazione timezone
dpkg-reconfigure tzdata

# Pulizia
apt-get clean

echo "Ora lancia rpi-update e poi esci dal chroot digitando exit"
