#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu dolphin
/usr/bin/flatpak run org.DolphinEmu.dolphin-emu
rclone_uploadEmu dolphin