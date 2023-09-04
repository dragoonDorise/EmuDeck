#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "rmg" && cloud_sync_startService
/usr/bin/flatpak run com.github.Rosalie241.RMG "${@}"
rm -rf "$savesPath/.gaming"