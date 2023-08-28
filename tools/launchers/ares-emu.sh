#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu ares
/usr/bin/flatpak run dev.ares.ares "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"
