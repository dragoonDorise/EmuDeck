#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "duckstation" && cloud_sync_startService
/usr/bin/flatpak run org.duckstation.DuckStation "${@}"
rm -rf "$savesPath/.gaming"