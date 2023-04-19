#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu mame
/usr/bin/flatpak run org.mamedev.MAME
rclone_uploadEmu mame