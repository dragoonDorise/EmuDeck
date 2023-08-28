#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu melonds
/usr/bin/flatpak run net.kuribo64.melonDS "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"