#!/bin/bash

cd ~/CFS2

sudo rm -rf ~/CFS2/bootfs
sudo rm -rf ~/CFS2/chroot/lib/modules
sudo mkdir ~/CFS2/bootfs
sudo mkdir ~/CFS2/chroot/lib/modules

sudo cp -R firmware/hardfp/opt/* chroot/opt/
sudo cp -R firmware/modules/* chroot/lib/modules/
sudo cp -R firmware/boot/* bootfs