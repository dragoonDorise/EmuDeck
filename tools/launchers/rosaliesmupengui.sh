#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu rmg
/usr/bin/flatpak run com.github.Rosalie241.RMG
rclone_uploadEmu rmg