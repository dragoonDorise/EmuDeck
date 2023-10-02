#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "ares" && cloud_sync_startService
/usr/bin/flatpak run dev.ares.ares "${@}"
rm -rf "$savesPath/.gaming"
