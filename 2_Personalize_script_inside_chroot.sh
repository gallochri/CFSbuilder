#!/bin/bash

# Aggiunta repository standard
rm -r /etc/apt/sources.list
echo "deb http://archive.raspbian.org/raspbian wheezy main non-free" >> /etc/apt/sources.list
echo "deb http://archive.raspberrypi.org/debian/ wheezy main" >> /etc/apt/sources.list
wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -
# Aggiunta repository Mate
echo "deb http://archive.raspbian.org/mate wheezy main" >> /etc/apt/sources.list
# Aggiunta repository Collabora
echo "deb http://raspberrypi.collabora.com wheezy rpi" >> /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 0C50B1C5
	
#TODO testare se funziona ancora il servizio
echo "#############Registrazione CFS####################"
install -m 755 /root/sources/cfs-registration /etc/init.d/
update-rc.d cfs-registration defaults

echo "#############Generatore di Hostname###############"
sh -c 'echo raspberrypi >/etc/hostname'
sh -c 'echo 127.0.0.1	raspberrypi >>/etc/hosts'
install -m 755 /root/sources/name_generator /usr/local/bin/
install -m 755 /root/sources/hostname.sh /etc/init.d/
install -m 755 /root/sources/hostname_changed.sh /etc/init.d/
update-rc.d hostname_changed.sh defaults 36 S .

# Copiatura configurazione eth0 con DHCP e wpa supplicant
cp -r /root/config/etc/network/interfaces /etc/network/interfaces

# Configurazione fstab per SD card
sh -c 'cat > /etc/fstab << EOF
proc /proc proc defaults 0 0
/dev/mmcblk0p1 /boot vfat defaults 0 0
EOF
'
# Profilo Bash per root
cp -r /root/config/root/bashrc /root/
cp -r /root/config/root/profile /root/

# Aggiornamento archivi
apt-get update

echo "##########Installazione sistema di base##########"
apt-get install -y locales sudo openssh-server ntp patch less rsync raspi-config usbmount

echo "###############Creazione utente pi###############"
adduser --gecos "" pi
# TODO Mettendo l'opzione --disabled-password si crea un utente senza password.
# L'utente così creato non fa il login in X, probabile ci sia da configurare X 
# in modo da permettere il login senza password.
#--disabled-password 

echo "##########Installazione pacchetti base###########"
apt-get install -y bash-completion blt build-essential cgroup-bin curl
apt-get install -y debconf-utils debian-reference-common debian-reference-it
apt-get install -y dhcpcd5 dphys-swapfile ed esound-common fake-hwclock fbset fonts-freefont-ttf fonts-roboto
apt-get install -y gdb gdbserver gettext-base gir1.2-glib-2.0 git git-core git-man gksu gnome-icon-theme-symbolic 
apt-get install -y gvfs-backends gvfs-fuse hardlink idle idle-python2.7 idle-python3.2 idle3 python-tk ifplugd i2c-tools
apt-get install -y jackd jackd2 manpages-dev mawk menu menu-xdg ncdu nfs-common nuscratch omxplayer openresolv openssl oracle-java8-jdk
apt-get install -y pkg-config poppler-data poppler-utils pypy-setuptools pypy-upstream pypy-upstream-dev pypy-upstream-doc python-numpy 
apt-get install -y python-picamera python-pifacecommon python-pifacedigitalio python-pygame python-rpi.gpio python-serial python3-numpy 
apt-get install -y python3-picamera python3-pifacecommon python3-pifacedigital-scratch-handler python3-pifacedigitalio python3-pygame
apt-get install -y python3-rpi.gpio python3-serial raspberrypi-artwork rpi-update smartsim sonic-pi ssh strace
apt-get install -y supercollider supercollider-common supercollider-server timidity timidity-daemon usbutils v4l-utils vim
apt-get install -y wireless-tools wpagui wpasupplicant xserver-xorg-video-fbturbo x2x xinit xserver-xorg-video-fbdev

echo "#########Installazione pacchetti non-free##########"
apt-get install -y firmware-atheros firmware-libertas firmware-ralink firmware-realtek

echo "####################Wayland########################"
apt-get install -y weston

echo "################Installazione mate#################"
apt-get install -y mate-core mate-desktop-environment

echo "###########Installazione Desktop Manager###########"
apt-get install -y lightdm

echo "###################Programmi CFS###################"
apt-get -y install tightvncserver
su -l pi -c "mkdir -p ~/.config/autostart/"
install -m 755 -o pi /root/config/home/pi/autostart/autotightvnc.desktop \
	/home/pi/.config/autostart
install -m 755 /root/config/home/pi/autostart/tightvnc.desktop \
        /usr/share/applications
apt-get -y install chromium-browser
apt-get -y install geogebra
update-alternatives --set java /usr/lib/jvm/jdk-8-oracle-arm-vfp-hflt/jre/bin/java
apt-get -y install iceweasel iceweasel-l10n-it
apt-get -y install -y avahi-daemon cifs-utils

# Aggiunta dell'utente Pi ai gruppi
groupadd -g 999 input
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,netdev,spi,gpio,i2c,input pi

# Autologin per utente pi
update-alternatives --set x-session-manager /usr/bin/mate-session
update-rc.d lightdm enable 2
sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=.*/autologin-user=pi/"

# Configurazione usbmount.conf
sed -i -e 's/""/"-fstype=vfat,flush,gid=plugdev,dmask=0007,fmask=0117"/g' /etc/usbmount/usbmount.conf

# Inittab per serial console
cp -r /root/config/etc/inittab /etc/inittab

# wpa supplicant
cp -r /root/config/etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/

# Configurazione Locale
# installare anche en_GB.UTF-8
dpkg-reconfigure locales

# Configurazione tastiera
# TODO Probabile non sia necessaria in quando la configurazione avviene qaundo si installa il pacchetto
dpkg-reconfigure keyboard-configuration &&
printf "Reloading keymap. This may take a short while\n" &&
invoke-rc.d keyboard-setup start

# Configurazione timezone
dpkg-reconfigure tzdata

# Aggiornamento
apt-get -y upgrade 

# Pulizia
apt-get clean

echo "Ora lancia rpi-update e poi esci dal chroot digitando exit"
