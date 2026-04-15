#!/bin/sh
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "supermodel"
param="${@}"
param=$(echo "$param" | sed "s|'||g")
/usr/bin/flatpak run com.supermodel3.Supermodel "${param}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";