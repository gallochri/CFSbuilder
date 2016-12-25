#!/bin/bash

echo "###############Creazione utente pi###############"
adduser --gecos "" pi
# TODO Mettendo l'opzione --disabled-password si crea un utente senza password.
# TODO L'utente fa il login in automatico ma se esce dalla sessione non può fare il login da DM.

# Aggiunta repository standard
cp -rf /root/config/etc/apt /etc/

# Aggiunta repository Mate
# echo "deb http://archive.raspbian.org/mate jessie main" >> /etc/apt/sources.list

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
EOF
'

# Profilo Bash per root
cp -r /root/config/root/bashrc /root/.bashrc
cp -r /root/config/root/profile /root/.profile

# Aggiornamento archivi
apt-get update

echo "##########Installazione sistema di base##########"

apt-get install -y apt-listchanges
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

#Audio
apt-get install -y jackd jackd2
#Per forzare l'audio HDMI
#amixer cset numid=3 2

apt-get install -y ifplugd wpasupplicant
# Copiatura configurazione eth0 con DHCP e wpa supplicant
cp -r /root/config/etc/network/interfaces /etc/network/interfaces
#cp -r /root/config/etc/default/ifplugd /etc/default/ifplugd
cp -r /root/config/etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/

apt-get install -y openssh-server patch rsync raspi-config usbmount

#Regole udev
cp -r /root/config/etc/udev/* /etc/udev/

#Moduli da caricare al boot
cp -r /root/config/etc/modules /etc/modules

echo "##################################"
echo "##########Pacchetti B-E###########"
echo "##################################"
apt-get autoremove
apt-get install -y avahi-daemon adwaita-icon-theme alacarte alsa-base aspell aspell-en aspell-it
apt-get install -y bash-completion bind9-host binutils blt bluej bluez-firmware bluez build-essential
apt-get install -y chromium-browser cifs-utils claws-mail coinor-libcoinmp1 crda cups-bsd curl
apt-get install -y dc debconf-utils debian-reference-common debian-reference-en debian-reference-it
apt-get install -y desktop-base desktop-file-utils device-tree-compiler dhcpcd5 dillo dosfstools dphys-swapfile
apt-get install -y ed esound-common
echo "##################################"
echo "##########Pacchetti F-M###########"
echo "##################################"
apt-get install -y fake-hwclock fbset
apt-get install -y firmware-atheros firmware-brcm80211 firmware-libertas firmware-ralink firmware-realtek
apt-get install -y fontconfig-infinality fonts-dejavu fonts-droid fonts-freefont-ttf fonts-opensymbol
apt-get install -y fonts-roboto fonts-sil-gentium-basic fuse
apt-get install -y galculator gdb gettext-base gdebi-core geany gettext-base giblib1 git git-core gksu
apt-get install -y gnome-desktop3-data gnome-icon-theme gnome-icon-theme-symbolic gnome-themes-standard gpicview
apt-get install -y greenfoot gsfonts gsfonts-x11 gstreamer0.10-alsa gstreamer0.10-plugins-base gstreamer1.0-alsa
apt-get install -y gstreamer1.0-libav gstreamer1.0-omx gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gtk2-engines
apt-get install -y gtk2-engines-clearlookspix gvfs-backends gvfs-fuse
apt-get install -y hardlink
apt-get install -y i2c-tools idle idle3
apt-get install -y javascript-common
apt-get install -y leafpad libabw-0.1-1 libasound2-plugins libaudiofile1 libavahi-client3 libavahi-gobject0
apt-get install -y libboost-atomic1.55.0 libboost-date-time1.55.0 libboost-filesystem1.55.0
apt-get install -y libboost-program-options1.55.0 libboost-regex1.55.0 libboost-thread1.55.0 libc-ares2 libcdr-0.1-1
apt-get install -y libcanberra-gtk3-0 libclucene-contribs1 libcmis-0.4-4 libcolamd2.8.0 libcwiid1 libdirectfb-1.2-9
apt-get install -y libfreetype6-dev libgnome-desktop-3-10 libgles1-mesa libglew1.10 libllvm3.7 libmozjs185-1.0
apt-get install -y libportaudio2 libraspberrypi-bin libraspberrypi-dev libraspberrypi-doc libreoffice libreoffice-gtk
apt-get install -y luajit lxappearance lxde lxkeymap
apt-get install -y minecraft-pi module-init-tools
apt-get install -y ncdu netsurf-common netsurf-gtk nfs-common nodejs nodejs-legacy nodered nuscratch
echo "##################################"
echo "##########Pacchetti O-P###########"
echo "##################################"
apt-get install -y omxplayer oracle-java8-jdk
apt-get install -y packagekit penguinspuzzle pi-greeter pi-package pi-package-data pi-package-data pi-package-session
apt-get install -y piclone pimixer pipanel pishutdown pix-icons pix-plym-splash pixel-wallpaper pkg-config
apt-get install -y plymouth-themes point-rpi pprompt pypy python-blinker python-colorama python-distlib python-flask
apt-get install -y python-gpiozero python-html5lib python-ndg-httpsclient python-picamera python-picraft
apt-get install -y python-pifacecommon python-pifacedigitalio python-pigpio python-pygame python-pil python-pip
apt-get install -y python-rtimulib python-sense-emu python-sense-emu-doc python-sense-hat python-smbus python-twython
apt-get install -y python3-codebug-i2c-tether python3-codebug-tether python3-colorama python3-dev python3-distlib
apt-get install -y python3-flask python3-gpiozero python3-html5lib python3-pgzero python3-picamera
apt-get install -y python3-picraft python3-pifacecommon python3-pifacedigital-scratch-handler python3-pigpio
apt-get install -y python3-pip python3-requests python3-rtimulib python3-sense-hat python3-smbus python3-twython
echo "##################################"
echo "##########Pacchetti R-Z###########"
echo "##################################"
apt-get install -y raspberrypi-artwork raspberrypi-net-mods raspberrypi-sys-mods raspberrypi-ui-mods
apt-get install -y raspi-copies-and-fills raspi-gpio rc-gui realvnc-vnc-server realvnc-vnc-viewer ril.9.1
apt-get install -y rpi-chromium-mods rpi-update ruby ruby1.9.1-dev ruby1.9.1-full ruby1.9.3
apt-get install -y sense-hat smartsim sonic-pi ssh strace supercollider
apt-get install -y timidity tree
apt-get install -y usb-modeswitch usb-modeswitch-data
apt-get install -y v4l-utils vdpau-va-driver
apt-get install -y wiringpi wolfram-engine
apt-get install -y x2x xcompmgr xinit xpdf xserver-xorg
apt-get install -y zlib1g-dev

# source profile at login
cp -r /root/config/etc/X11/Xsession.d/* /etc/X11/Xsession.d/

echo "###################################################"
echo "###################Programmi CFS###################"
echo "###################################################"

echo "#############Registrazione CFS####################"
install -m 755 /root/sources/cfs-registration /etc/init.d/
install -m 644 /root/config/lib/systemd/system/cfs-registration.service /lib/systemd/system/cfs-registration.service
systemctl enable cfs-registration

echo "#############Generatore di Hostname###############"
install -m 755 /root/sources/name_generator /usr/local/bin/
install -m 755 /root/sources/hostname.sh /etc/init.d/
install -m 755 /root/sources/hostname_changed.sh /etc/init.d/
install -m 644 /root/config/lib/systemd/system/cfs-hostname.service /lib/systemd/system/cfs-hostname.service
systemctl enable cfs-hostname

# TightVNC
apt-get install -y tightvncserver
su -l pi -c "mkdir -p ~/.config/autostart/"
install -m 755 -o pi /root/config/home/pi/autostart/autotightvnc.desktop \
	/home/pi/.config/autostart
install -m 755 /root/config/home/pi/autostart/tightvnc.desktop \
        /usr/share/applications

apt-get -y install geogebra
update-alternatives --set java /usr/lib/jvm/jdk-8-oracle-arm-vfp-hflt/jre/bin/java
apt-get -y install lirc liblircclient-dev

# Aggiunta dell'utente Pi ai gruppi
groupadd -g 997 gpio
groupadd -g 998 i2c
groupadd -g 999 spi
usermod -a -G adm,audio,dialout,cdrom,games,gpio,i2c,input,netdev,plugdev,spi,sudo,users,video pi

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

echo "##############Install Pibrella python modules#######"
pip3 install pibrella
pip install pibrella

echo "###################Clean desktop###################"
apt-get clean
# Aggiornamento
apt-get -y upgrade

#TODO: Rivedere tutta la personalizzazione grafica
# echo "###################ArtWork#########################"
# mkdir /home/pi/.cfs-artwork/
# mv /root/artwork/ /home/pi/.cfs-artwork/
# chown -R pi:pi /home/pi/
# su -l pi -c "dbus-launch --exit-with-session gsettings set org.mate.background picture-filename '/home/pi/.cfs-artwork/cfs-wallpaper.png'"


echo "Ora lancia rpi-update e poi esci dal chroot digitando exit"
