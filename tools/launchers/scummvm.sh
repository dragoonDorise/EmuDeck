#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu scummvm
/usr/bin/flatpak run org.scummvm.ScummVM
rclone_uploadEmu scummvm