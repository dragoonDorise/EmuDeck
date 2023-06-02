#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu duckstation
/usr/bin/flatpak run org.duckstation.DuckStation -bigpicture -fullscreen
rclone_uploadEmu duckstation