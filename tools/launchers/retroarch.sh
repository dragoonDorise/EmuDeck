#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu retroarch
/usr/bin/flatpak run org.libretro.RetroArch
rclone_uploadEmu retroarch