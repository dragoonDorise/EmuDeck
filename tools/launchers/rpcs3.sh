#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu rpcs3
/usr/bin/flatpak run net.rpcs3.RPCS3
rclone_uploadEmu rpcs3