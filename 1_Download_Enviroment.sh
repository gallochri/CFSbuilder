#!/bin/bash

OS_NAME=`lsb_release -i -s`

cd ~
mkdir -p ~/CFS2

while true; do
	if [ -d ~/CFS2/chroot ]; then
		read -p "Esiste già una chroot, vuoi sovrascriverla [s/n]?" -n 1 -r -s
		case $REPLY in
			[s]* ) echo -e "\nCancellazione chroot e creazione nuova debootstrap "; sudo rm -r ~/CFS2/chroot;;
			[n]* ) case $OS_NAME in
				Debian | Ubuntu)
					sudo cp /usr/bin/qemu-arm-static ~/CFS2/chroot/usr/bin/qemu-arm-static;break;;
				"openSUSE project")
					sudo qemu-binfmt-conf.sh;
    				sudo cp /usr/bin/qemu-arm-binfmt CFS2/chroot/usr/bin/;
    				sudo sudo cp /usr/bin/qemu-arm CFS2/chroot/usr/bin/;break;;
    			esac;;
			* ) echo -e "\nPremere [s] per ripartire con una chroot pulita oppure [n] per utilizzare quella esistente";;
		esac
	else
		case $OS_NAME in 
			Debian | Ubuntu) 
    			sudo apt-get -y install qemu-user-static debootstrap git kpartx;
    			sudo qemu-debootstrap --no-check-gpg --arch armhf wheezy ~/CFS2/chroot http://archive.raspbian.org/raspbian;break;;
			"openSUSE project")
    			sudo zypper in -n qemu-linux-user debootstrap git kpartx;
    			sudo debootstrap --no-check-gpg --foreign --arch armhf wheezy ~/CFS2/chroot http://archive.raspbian.org/raspbian;
    			sudo qemu-binfmt-conf.sh;
    			sudo cp /usr/bin/qemu-arm-binfmt CFS2/chroot/usr/bin/;
    			sudo sudo cp /usr/bin/qemu-arm CFS2/chroot/usr/bin/;
    			sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true  LC_ALL=C LANGUAGE=C LANG=C chroot ~/CFS2/chroot/ /debootstrap/debootstrap --second-stage;break;;
		esac
	fi
done

cd ~/CFS2

while true; do
	read -p "Clonare il firmware da zero o aggiornarlo [c/a]?" -n 1 -r -s
	case $REPLY in
		[c]* ) echo -e;sudo rm -rf firmware; sudo git clone https://github.com/raspberrypi/firmware.git; break;;
		[a]* ) echo -e "\nOK!";cd firmware; sudo git fetch origin; sudo git reset --hard origin/master; break;;
		* ) echo -e "\nPremere [c] clona oppure [a] aggiorna.";;
	esac
done

echo "Finito!"
