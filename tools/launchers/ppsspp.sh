#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu ppsspp
/usr/bin/flatpak run org.ppsspp.PPSSPP "${@}"
cloud_sync_uploadEmu ppsspp