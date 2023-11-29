#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "melonds" && cloud_sync_startService
/usr/bin/flatpak run net.kuribo64.melonDS "${@}"
rm -rf "$savesPath/.gaming"