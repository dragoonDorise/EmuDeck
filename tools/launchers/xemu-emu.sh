#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "xemu" && cloud_sync_startService
/usr/bin/flatpak run app.xemu.xemu "${@}"
rm -rf "$savesPath/.gaming" 