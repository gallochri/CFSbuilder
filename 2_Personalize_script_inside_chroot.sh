#!/bin/bash

# Aggiunta repository standard
cp -rf /root/config/etc/apt /etc/
#rm -r /etc/apt/sources.list
#echo "deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi" >> /etc/apt/sources.list
# Aggiunta repository Mate
echo "deb http://archive.raspbian.org/mate jessie main" >> /etc/apt/sources.list
# Aggiunta chiavi repository
wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -

# Aggiunta repository Collabora
# NOTE:Serviva per il pachhetto weston in wheezy
#echo "deb http://raspberrypi.collabora.com wheezy rpi" >> /etc/apt/sources.list
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 0C50B1C5
	
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
apt-get install -y locales sudo openssh-server ntp patch less rsync raspi-config usbmount

echo "###############Creazione utente pi###############"
adduser --gecos "" pi
# TODO Mettendo l'opzione --disabled-password si crea un utente senza password.
# L'utente così creato non fa il login in X, probabile ci sia da configurare X 
# in modo da permettere il login senza password.
#--disabled-password 

echo "##########Installazione pacchetti base###########"
apt-get install -y alsa-base aspell aspell-en aspell-it avahi-daemon
apt-get install -y bash-completion binutils blt build-essential bzip2
apt-get install -y ca-certificates cifs-utils console-setup console-setup-linux cryptsetup-bin cups-bsd cups-client cups-common curl
apt-get install -y dbus-x11 dc dconf-gsettings-backend:armhf debconf-utils debian-reference-common debian-reference-it dhcpcd5 dphys-swapfile
apt-get install -y ed eject esound-common
apt-get install -y fake-hwclock fbset fontconfig fonts-dejavu fonts-dejavu-extra fonts-freefont-ttf fonts-opensymbol fonts-sil-gentium-basic fonts-roboto fuse
apt-get install -y gdb gdbserver gettext-base git git-core git-man gksu gvfs-backends gvfs-fuse
apt-get install -y idle idle-python2.7 idle-python3.4 idle3 ifplugd
apt-get install -y jackd jackd2 java-common javascript-common
apt-get install -y ncdu nfs-common nuscratch
apt-get install -y omxplayer openresolv oracle-java8-jdk
apt-get install -y poppler-utils pypy-setuptools pypy-upstream pypy-upstream-dev pypy-upstream-doc
apt-get install -y python-picamera python-pifacecommon python-pifacedigitalio python-pygame python-rpi.gpio python-serial python3-numpy
apt-get install -y python3-picamera python3-pifacecommon python3-pifacedigital-scratch-handler python3-pifacedigitalio python3-pygame
apt-get install -y python3-rpi.gpio python3-serial
apt-get install -y raspberrypi-artwork raspberrypi-net-mods  raspi-gpio rpi-update
apt-get install -y smartsim sonic-pi ssh strace supercollider supercollider-common supercollider-server timidity usbutils v4l-utils vim
apt-get install -y wireless-tools wpagui wpasupplicant wiringpi
apt-get install -y xserver-xorg-video-fbturbo x2x xinit xserver-xorg-video-fbdev

echo "#########Installazione pacchetti non-free##########"
apt-get install -y firmware-atheros firmware-brcm80211 firmware-libertas firmware-ralink firmware-realtek

echo "################Installazione mate#################"
apt-get install -y mate-core mate-desktop-environment mate-bluetooth

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

# Inittab per serial console
cp -r /root/config/etc/inittab /etc/inittab

# wpa supplicant
cp -r /root/config/etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/

# Configurazione Locale
# installare anche en_GB.UTF-8
dpkg-reconfigure locales

# Configurazione timezone
dpkg-reconfigure tzdata

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
pip-3.2 install pibrella

echo "##############Install Pibrella python module########"
apt-get -y install python-pip
pip install pibrella

echo "###################Clean desktop###################"
rm -rf /home/pi/Desktop/*
apt-get clean

echo "###################ArtWork#########################"
mkdir /home/pi/.cfs-artwork/
mv /root/artwork/ /home/pi/.cfs-artwork/
chown -R pi:pi /home/pi/
su -l pi -c "dbus-launch --exit-with-session gsettings set org.mate.background picture-filename '/home/pi/.cfs-artwork/cfs-wallpaper.png'"


echo "Ora lancia rpi-update e poi esci dal chroot digitando exit"
