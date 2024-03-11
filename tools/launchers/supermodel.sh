#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "supermodel"
param="${@}"
param=$(echo "$param" | sed "s|'||g")
/usr/bin/flatpak run com.supermodel3.Supermodel "${param}"
rm -rf "$savesPath/.gaming"