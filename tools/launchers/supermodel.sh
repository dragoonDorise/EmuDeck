#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "supermodel" && cloud_sync_startService
param="${@}"
param=$(echo "$param" | sed "s|'|\"|g")
/usr/bin/flatpak run com.supermodel3.Supermodel "${param}"
rm -rf "$savesPath/.gaming"