#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "ppsspp" && cloud_sync_startService
/usr/bin/flatpak run org.ppsspp.PPSSPP "${@}"
rm -rf "$savesPath/.gaming"