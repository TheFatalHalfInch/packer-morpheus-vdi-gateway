#!/bin/bash
#create a randomized temporary directory
tempdir="$(mktemp -d)"

#filename
morpheus="morpheus-appliance_5.4.2-2_amd64.deb"

#install open-vm-tools
apt-get -y install open-vm-tools

#disable cloud-init to allow cloning from vsphere template
touch /etc/cloud/cloud-init.disabled

#package updates
apt-get -y update
apt-get -y upgrade

#download the morpheus installer package
wget https://downloads.morpheusdata.com/files/"$morpheus" -P "$tempdir"

#install morpheus
dpkg -i "$tempdir/$morpheus"

#reconfigure morpheus after the installation
morpheus-ctl reconfigure

#morpheus status
morhpeus-ctl status