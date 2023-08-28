#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu xemu
/usr/bin/flatpak run app.xemu.xemu "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching" 