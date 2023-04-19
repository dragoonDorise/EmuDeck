#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu pcsx2
/usr/bin/flatpak run net.pcsx2.PCSX2
rclone_uploadEmu pcsx2