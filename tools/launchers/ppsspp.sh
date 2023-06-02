#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu ppsspp
/usr/bin/flatpak run org.ppsspp.PPSSPP
rclone_uploadEmu ppsspp