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

# Aggiunta utente standard
adduser --disabled-password --gecos "" pi
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,netdev,input,spi,i2c,gpio pi


apt-get install -y bash-completion blt build-essential
apt-get install -y cgroup-bin cifs-utils curl
apt-get install -y debconf-utils debian-reference-common debian-reference-en dhcpcd5 dillo dphys-swapfile
apt-get install -y ed esound-common
#apt-get install -y firmware-atheros firmware-libertas firmware-ralink firmware-realtek
apt-get install -y fake-hwclock fbset fonts-freefont-ttf fonts-roboto
apt-get install -y galculator gdb gdbserver gettext-base
apt-get install -y gir1.2-glib-2.0 git git-core git-man gksu 
apt-get install -y gnome-icon-theme-symbolic gpicview gvfs-backends gvfs-fuse
apt-get install -y hardlink
apt-get install -y idle idle-python2.7 idle-python3.2 idle3 python-tk ifplugd ifupdown
apt-get install -y python3 python3-minimal python3-tk python3.2 python3.2-minimal
apt-get install -y jackd jackd2 
apt-get install -y leafpad
apt-get install -y make makedev man-db manpages manpages-dev mawk menu menu-xdg mime-support minecraft-pi module-init-tools mount mountall multiarch-support
apt-get install -y nano ncdu ncurses-base ncurses-bin ncurses-term net-tools netbase netcat-openbsd netcat-traditional netsurf-common netsurf-gtk nfs-common ntp nuscratch                                         
apt-get install -y obconf omxplayer openbox openresolv openssh-blacklist openssh-blacklist-extra openssh-client openssh-server openssl oracle-java8-jdk
apt-get install -y parted passwd pciutils perl perl-base perl-modules pkg-config plymouth policykit-1 poppler-data 
apt-get install -y poppler-utils procps psmisc pypy-setuptools pypy-upstream pypy-upstream-dev pypy-upstream-doc 
apt-get install -y python python-dbus python-dbus-dev python-gi python-minecraftpi python-minimal python-numpy 
apt-get install -y python-picamera python-pifacecommon python-pifacedigitalio python-pygame python-rpi.gpio 
apt-get install -y python-serial python-support python-tk python2.7 python2.7-minimal python3 python3-minecraftpi python3-minimal python3-numpy 
apt-get install -y python3-picamera python3-pifacecommon python3-pifacedigital-scratch-handler python3-pifacedigitalio python3-pygame python3-rpi.gpio python3-serial python3-tk python3.2 python3.2-minimal  
apt-get install -y qdbus qjackctl
apt-get install -y raspberrypi-artwork  rpcbind rpi-update
apt-get install -y scratch smartsim sonic-pi ssh strace supercollider supercollider-common supercollider-server
apt-get install -y timidity timidity-daemon tsconf
apt-get install -y udev usbutils
apt-get install -y v4l-utils
apt-get install -y wireless-tools wpagui
#apt-get install -y weston
apt-get install -y xpdf xserver-xorg-video-fbturbo zenity x2x xarchiver xfconf xinit xserver-xorg-video-fbdev

echo "##########Utily############"
apt-get install -y wpasupplicant vim

echo "##############Installazione server X##############"
apt-get install -y lightdm

echo "################Installazione mate################"
apt-get install -y mate-core mate-desktop-environment

echo "##################Programmi CFS###################"

apt-get -y install chromium-browser
apt-get -y install geogebra
update-alternatives --set java /usr/lib/jvm/jdk-8-oracle-arm-vfp-hflt/jre/bin/java
apt-get -y install iceweasel iceweasel-l10n-it
apt-get -y install avahi-daemon

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
