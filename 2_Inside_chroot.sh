#!/bin/bash

while true; do
  echo -e "\n"
  read -p "Al termine di questo script sarai all'interno del chroot di Raspbian.
Per continuare la personalizzazione scarica lo script:
wget https://raw.githubusercontent.com/gallochri/CFSbuilder/master/3_Personalize.sh
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

# Dentro il chroot
sudo LC_ALL=C chroot ~/CFS2/chroot
