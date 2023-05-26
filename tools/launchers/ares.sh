#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu ares
/usr/bin/flatpak dev.ares.ares
rclone_uploadEmu ares
