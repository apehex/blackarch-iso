#!/bin/bash

# exit on error and undefined variables
set -eu

# set locale
locale-gen

# enable useful services and display manager
enabled_services=('choose-mirror.service' 'lightdm.service' 'dbus' 'pacman-init'
  'NetworkManager' 'irqbalance' 'vboxservice')
systemctl enable ${enabled_services[@]}
systemctl set-default graphical.target

# disable network stuff
rm -f /etc/udev/rules.d/81-dhcpcd.rules
systemctl disable dhcpcd sshd rpcbind.service

# repo + database
curl -s https://blackarch.org/strap.sh | sh
pacman -Syy --noconfirm
pacman-key --init
pacman-key --populate blackarch archlinux
pacman -Fyy
pacman-db-upgrade
sync

# font configuration
ln -sf /etc/fonts/conf.avail/* /etc/fonts/conf.d
rm -f /etc/fonts/conf.d/05-reset-dirs-sample.conf
rm -f /etc/fonts/conf.d/09-autohint-if-no-hinting.conf

# Temporary fix for calamares
pacman -U --noconfirm https://archive.archlinux.org/packages/d/dosfstools/dosfstools-4.1-3-x86_64.pkg.tar.xz
