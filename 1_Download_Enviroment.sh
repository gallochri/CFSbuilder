#!/bin/bash

OS_NAME=`lsb_release -i -s`
CURRENT_DIR=`pwd`

cd ~
mkdir -p ~/CFS2

while true; do
	if [ -d ~/CFS2/chroot ]; then
		read -p "Esiste già una chroot, vuoi sovrascriverla [s/n]?" -n 1 -r -s
		case $REPLY in
			#TODO Verificare che non ci siano filesystem montati nella chroot altrimenti scappella
			[s]* ) echo -e "\nCancellazione chroot e creazione nuova debootstrap "; sudo rm -r ~/CFS2/chroot;;
			[n]* ) case $OS_NAME in
				Debian | Ubuntu)
					echo -e;
					sudo cp /usr/bin/qemu-arm-static ~/CFS2/chroot/usr/bin/qemu-arm-static;break;;
				"openSUSE project" | "SUSE LINUX")
					echo -e;
					sudo qemu-binfmt-conf.sh;
    				sudo cp /usr/bin/qemu-arm-binfmt CFS2/chroot/usr/bin/;
    				sudo sudo cp /usr/bin/qemu-arm CFS2/chroot/usr/bin/;break;;
    			* )
    				echo -e;
    				echo "Sistema non supportato";
    				exit;;
    			esac;;
			* ) echo -e "\nPremere [s] per ripartire con una chroot pulita oppure [n] per utilizzare quella esistente";;
		esac
	else
		case $OS_NAME in 
			Debian | Ubuntu) 
    			sudo apt-get -y install qemu-user-static debootstrap git kpartx;
    			sudo qemu-debootstrap --no-check-gpg --arch armhf jessie ~/CFS2/chroot http://archive.raspbian.org/raspbian;break;;
			"openSUSE project" | "SUSE LINUX")
    			sudo zypper in -n qemu-linux-user debootstrap git kpartx;
    			sudo debootstrap --no-check-gpg --foreign --arch armhf jessie ~/CFS2/chroot http://archive.raspbian.org/raspbian;
    			sudo qemu-binfmt-conf.sh;
    			sudo cp /usr/bin/qemu-arm-binfmt CFS2/chroot/usr/bin/;
    			sudo sudo cp /usr/bin/qemu-arm CFS2/chroot/usr/bin/;
    			sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true  LC_ALL=C LANGUAGE=C LANG=C chroot ~/CFS2/chroot/ /debootstrap/debootstrap --second-stage;break;;
			* )
    			echo -e;
    			echo "Sistema non supportato";
    			exit;;
		esac
	fi
done

cd ~/CFS2
if [ -d ~/CFS2/firmware ]; then
	echo -e "\nCartella Firmware presente, Aggiono!";cd firmware; sudo git fetch origin; sudo git reset --hard origin/master
else
	echo -e;sudo rm -rf firmware; sudo git clone https://github.com/raspberrypi/firmware.git;
fi
		
while true; do
  echo -e "\n"
  read -p "Al termine di questo script sarai all'interno del chroot di Raspbian.
Puoi editare e poi lanciare lo script di personalizzazione con:
sh /root/2_Personalize_script_inside_chroot.sh
Premi [c]ontinua oppure [t]ermina." -n 1 -r -s
  case $REPLY in
	  [c]* )echo -e "";break;;
	  [t]* )exit;;
	  * )echo -e "\nPremere [c] per continuare oppure [t] per terminare.";;
  esac
done

#Montaggi FS
sudo mount -t proc proc ~/CFS2/chroot/proc
sudo mount -t sysfs sysfs ~/CFS2/chroot/sys
sudo mount -o bind /dev ~/CFS2/chroot/dev
sudo mount -o bind /dev/pts ~/CFS2/chroot/dev/pts

#Copia script e sorgenti all'interno della chroot
sudo rm -rf ~/CFS2/chroot/root/2_Personalize_script_inside_chroot.sh ~/CFS2/chroot/root/config ~/CFS2/chroot/root/sources
sudo cp ${CURRENT_DIR}/2_Personalize_script_inside_chroot.sh ~/CFS2/chroot/root/
sudo cp -r ${CURRENT_DIR}/sources/	~/CFS2/chroot/root/
sudo cp -r ${CURRENT_DIR}/config/	~/CFS2/chroot/root/
sudo cp -r ${CURRENT_DIR}/artwork/	~/CFS2/chroot/root/
			
# Dentro il chroot
sudo LC_ALL=C chroot ~/CFS2/chroot
