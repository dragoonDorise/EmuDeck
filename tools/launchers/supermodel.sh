#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "supermodel" && cloud_sync_startService
/usr/bin/flatpak run com.supermodel3.Supermodel "${@}"
rm -rf "$savesPath/.gaming"