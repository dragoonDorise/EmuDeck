#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu xemu
/usr/bin/flatpak run app.xemu.xemu
rclone_uploadEmu xemu