#!/bin/bash

echo "###############Creazione utente pi###############"
adduser --gecos "" pi
# --disabled-password
# TODO Mettendo l'opzione --disabled-password si crea un utente senza password.
# TODO L'utente così creato non fa il login in X, probabile ci sia da configurare X
# TODO in modo da permettere il login senza password.

# Aggiunta repository standard
cp -rf /root/config/etc/apt /etc/

# Aggiunta repository Mate
echo "deb http://archive.raspbian.org/mate jessie main" >> /etc/apt/sources.list

# Aggiunta chiavi repository
wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -

# Hostname
sh -c 'echo raspberrypi >/etc/hostname'
sh -c 'echo 127.0.0.1	raspberrypi >>/etc/hosts'

# Repair filesystem during boot
cp -r /root/config/etc/default/rcS /etc/default/rcS

# Configurazione fstab per SD card
sh -c 'cat > /etc/fstab << EOF
proc            /proc           proc    defaults          0       0
/dev/mmcblk0p1  /boot           vfat    defaults          0       2
/dev/mmcblk0p2  /               ext4    defaults,noatime  0       1
# a swapfile is not a swap partition, no line here
#   use  dphys-swapfile swap[on|off]  for that
EOF
'

# Profilo Bash per root
cp -r /root/config/root/bashrc /root/
cp -r /root/config/root/profile /root/

# Aggiornamento archivi
apt-get update

echo "##########Installazione sistema di base##########"

apt-get install -y locales
# Configurazione Locale
# en_GB.UTF-8
# it_IT.UTF_8
dpkg-reconfigure locales

apt-get install -y sudo
# configurazione Sudo
cp -r /root/config/etc/sudoers /etc/

apt-get install -y ntp
# Configurazione timezone
dpkg-reconfigure tzdata

apt-get install -y console-setup
# Configurazione della tastiera

apt-get install -y ifplugd wpasupplicant
# Copiatura configurazione eth0 con DHCP e wpa supplicant
cp -r /root/config/etc/network/interfaces /etc/network/interfaces
cp -r /root/config/etc/default/ifplugd /etc/default/ifplugd
mkdir /etc/wpa_supplicant/
cp -r /root/config/etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/

apt-get install -y openssh-server patch rsync raspi-config usbmount

echo "##########Installazione pacchetti base###########"
echo "##########Pacchetti B-E###########"
apt-get install -y bash-completion binutils blt build-essential
apt-get install -y ca-certificates cryptsetup-bin cups-bsd curl
apt-get install -y dbus-x11 dc dconf-gsettings-backend debconf-utils dhcpcd5
apt-get install -y ed eject esound-common
echo "##########Pacchetti F-M###########"
apt-get install -y fake-hwclock fbset fuse
apt-get install -y fontconfig fonts-dejavu fonts-freefont-ttf fonts-opensymbol fonts-sil-gentium-basic fonts-roboto
apt-get install -y gdb gettext-base git git-core gksu gvfs-backends gvfs-fuse
apt-get install -y idle idle3
apt-get install -y java-common javascript-common
apt-get install -y nfs-common nuscratch
echo "##########Pacchetti O-P###########"
apt-get install -y omxplayer oracle-java8-jdk
apt-get install -y poppler-utils pypy-setuptools
apt-get install -y python-picamera python-pifacecommon python-pifacedigitalio python-pygame python-rpi.gpio python-serial
apt-get install -y python3-numpy python3-picamera python3-pifacecommon python3-pifacedigital-scratch-handler
apt-get install -y python3-pygame python3-rpi.gpio python3-serial
echo "##########Pacchetti R-X###########"
apt-get install -y raspberrypi-artwork raspberrypi-net-mods raspi-gpio rpi-update
apt-get install -y smartsim sonic-pi ssh strace timidity usbutils v4l-utils vim
apt-get install -y wireless-tools wpagui
apt-get install -y xserver-xorg-video-fbturbo x2x xinit xserver-xorg-video-fbdev x11-xserver-utils

echo "#########Installazione pacchetti non-free##########"
apt-get install -y firmware-atheros firmware-brcm80211 firmware-libertas firmware-ralink firmware-realtek

echo "################Installazione mate#################"
apt-get install -y mate-core mate-desktop-environment mate-bluetooth

echo "###########Installazione Desktop Manager###########"
apt-get install -y lightdm

echo "###################Programmi CFS###################"

#TODO con Jessie Debian è passata definitivamente a Systemd
#TODO Aggiornare gli script!
echo "#############Registrazione CFS####################"
#install -m 755 /root/sources/cfs-registration /etc/init.d/
#update-rc.d cfs-registration defaults

#TODO con Jessie Debian è passata definitivamente a Systemd
#TODO Aggiornare gli script!
echo "#############Generatore di Hostname###############"

#install -m 755 /root/sources/name_generator /usr/local/bin/
#install -m 755 /root/sources/hostname.sh /etc/init.d/
#install -m 755 /root/sources/hostname_changed.sh /etc/init.d/
#update-rc.d hostname_changed.sh defaults 36 S .

apt-get -y install tightvncserver
su -l pi -c "mkdir -p ~/.config/autostart/"
install -m 755 -o pi /root/config/home/pi/autostart/autotightvnc.desktop \
	/home/pi/.config/autostart
install -m 755 /root/config/home/pi/autostart/tightvnc.desktop \
        /usr/share/applications

#TODO Non c'è più chromium per raspberry, consuma troppa ram
#apt-get -y install chromium-browser
apt-get -y install geogebra
update-alternatives --set java /usr/lib/jvm/jdk-8-oracle-arm-vfp-hflt/jre/bin/java
apt-get -y install iceweasel iceweasel-l10n-it
apt-get -y install lirc liblircclient-dev
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



echo "##############Install scratch GPIO6################"
cd /home/pi
mkdir -p Desktop
wget https://raw.githubusercontent.com/cymplecy/scratch_gpio/V6/install_scratchgpio6.sh
bash install_scratchgpio6.sh
rm -rf install_scratchgpio6.sh
cd Desktop
sed -i "s/Application;Education;Development;/Development;/g" scratchgpio6*
mv scratchgpio6* /usr/share/applications/
cd /home/pi

# Aggiornamento
apt-get -y upgrade 

echo "##############Install Pibrella python3 module#######"
apt-get -y install python3-pip
pip3 install pibrella

echo "##############Install Pibrella python module########"
apt-get -y install python-pip
pip install pibrella

echo "###################Clean desktop###################"
rm -rf /home/pi/Desktop/*
apt-get clean

#TODO: Rivedere tutta la personalizzazione grafica
echo "###################ArtWork#########################"
mkdir /home/pi/.cfs-artwork/
mv /root/artwork/ /home/pi/.cfs-artwork/
chown -R pi:pi /home/pi/
su -l pi -c "dbus-launch --exit-with-session gsettings set org.mate.background picture-filename '/home/pi/.cfs-artwork/cfs-wallpaper.png'"


echo "Ora lancia rpi-update e poi esci dal chroot digitando exit"
