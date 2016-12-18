#!/bin/bash

OS_NAME=`lsb_release -i -s`
CURRENT_DIR=`pwd`
DEBIAN=false
SUSE=false

case ${OS_NAME} in
    "Debian" | "Ubuntu")
        echo "### DEBIAN derived detected.";
        DEBIAN=true;
        break;;
    "openSUSE project" | "SUSE LINUX" | "openSUSE" | "openSUSE Tumbleweed")
        echo "### SUSE derived detected.";
        SUSE=true;
        break;;
    * )
        echo -e;
   	    echo "### Unsupported System";exit;break;;
esac;

function opensuse_packages() {
    echo -e
    echo "### "${OS_NAME};
    echo "### Install missing package.";
    sudo zypper in -n qemu-linux-user debootstrap git kpartx;
}

function opensuse_chroot() {
    echo -e
    echo "### Building chroot...";
    sudo debootstrap --no-check-gpg --foreign --arch armhf jessie ~/CFS2/chroot http://archive.raspbian.org/raspbian;
    sudo qemu-binfmt-conf.sh;
    sudo cp /usr/bin/qemu-arm-binfmt ~/CFS2/chroot/usr/bin/;
    sudo cp /usr/bin/qemu-arm ~/CFS2/chroot/usr/bin/;
    sudo DEBIAN_FRONTEND=noninteractive \
         DEBCONF_NONINTERACTIVE_SEEN=true  \
         LC_ALL=C \
         LANGUAGE=C \
         LANG=C \
         chroot ~/CFS2/chroot/ /debootstrap/debootstrap --second-stage;
}

function debian_packages() {
    echo -e
    echo "### "${OS_NAME};
    echo "### Install missing package.";
    sudo apt-get -y install qemu-user-static debootstrap git kpartx;
}

function debian_chroot() {
    echo -e
    echo "### Building chroot...";
    sudo qemu-debootstrap --no-check-gpg --arch armhf jessie ~/CFS2/chroot http://archive.raspbian.org/raspbian;
    sudo cp /usr/bin/qemu-arm-static ~/CFS2/chroot/usr/bin/qemu-arm-static;
}


cd ~
mkdir -p ~/CFS2

while true; do
	if [ -d ~/CFS2/chroot ]; then
		read -p "### Detected existing chroot folder, do you want to overwrite it? [y/n]?" -n 1 -r -s
		case $REPLY in #TODO Verificare che non ci siano filesystem montati nella chroot altrimenti scappella
			[y]* )
			    echo -e "\n### Removing chroot and new debootstrap creation ";
			    sudo rm -r ~/CFS2/chroot;
			    if [ "$SUSE" = true ];
			        then opensuse_chroot;fi;
			    if [ "$DEBIAN" = true ];
			        then debian_chroot;fi;
			    break;;
			[n]* )
			    echo -e "\n### Continuing with the existing chroot";
			    sudo qemu-binfmt-conf.sh;
                sudo cp /usr/bin/qemu-arm-binfmt ~/CFS2/chroot/usr/bin/;
                sudo cp /usr/bin/qemu-arm ~/CFS2/chroot/usr/bin/;
                sudo DEBIAN_FRONTEND=noninteractive \
                     DEBCONF_NONINTERACTIVE_SEEN=true  \
                     LC_ALL=C \
                     LANGUAGE=C \
                     LANG=C \
                     chroot ~/CFS2/chroot/ /debootstrap/debootstrap --second-stage;break;;
			* ) echo -e "\n### Press [y] for new clean chroot or [n] for existing chroot";;
		esac
	else
	    if [ "$SUSE" = true ];
	    then opensuse_packages;opensuse_chroot;fi;
	    if [ "$DEBIAN" = true ];
	    then debian_packages;debian_chroot;fi;
	fi
done

cd ~/CFS2

if [ -d ~/CFS2/firmware ]; then
	echo -e "\n### Detect existing firmware folder, update!";
	cd firmware;
	sudo git fetch origin;
	sudo git reset --hard origin/master;
else
	echo -e; "\n### Cloning firmware.";
	sudo rm -rf firmware;
	sudo git clone https://github.com/raspberrypi/firmware.git;
fi
		
while true; do
  echo -e "\n"
  read -p "### At the end of this script you will be inside the Raspbian chroot and
  You can edit and then launch the customization script:
  sh /root/2_Personalize_script_inside_chroot.sh
  Press [c]ontinues or [e]nds." -n 1 -r -s
  case $REPLY in
	  [c]* )echo -e "";break;;
	  [e]* )echo -e;exit;break;;
	  * )echo -e "\n### Press [c]ontinues or [e]nds.";break;;
  esac
done

#Mount FS
sudo mount -t proc /proc ~/CFS2/chroot/proc
sudo mount -t sysfs /sysfs ~/CFS2/chroot/sys
sudo mount -o bind /dev ~/CFS2/chroot/dev
sudo mount -o bind /dev/pts ~/CFS2/chroot/dev/pts

#Copyng script inside chroot
sudo rm -rf ~/CFS2/chroot/root/2_Personalize_script_inside_chroot.sh ~/CFS2/chroot/root/config ~/CFS2/chroot/root/sources
sudo cp ${CURRENT_DIR}/2_Personalize_script_inside_chroot.sh ~/CFS2/chroot/root/
sudo cp -r ${CURRENT_DIR}/sources/	~/CFS2/chroot/root/
sudo cp -r ${CURRENT_DIR}/config/	~/CFS2/chroot/root/
sudo cp -r ${CURRENT_DIR}/artwork/	~/CFS2/chroot/root/
			
# Go into chroot
sudo LC_ALL=C chroot ~/CFS2/chroot

