#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu primehack
/usr/bin/flatpak run io.github.shiiion.primehack "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"