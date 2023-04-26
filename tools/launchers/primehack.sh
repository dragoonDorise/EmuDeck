#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu primehack
/usr/bin/flatpak run io.github.shiiion.primehack
rclone_uploadEmu primehack