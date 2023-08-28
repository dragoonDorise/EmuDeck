#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu duckstation
/usr/bin/flatpak run org.duckstation.DuckStation "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"