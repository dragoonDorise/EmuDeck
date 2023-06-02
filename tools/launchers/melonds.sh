#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu melonds
/usr/bin/flatpak run net.kuribo64.melonDS
rclone_uploadEmu melonds