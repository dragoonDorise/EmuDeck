#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "primehack" && cloud_sync_startService
/usr/bin/flatpak run io.github.shiiion.primehack "${@}"
rm -rf "$savesPath/.gaming"