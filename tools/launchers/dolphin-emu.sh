#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "dolphin" && cloud_sync_startService
/usr/bin/flatpak run org.DolphinEmu.dolphin-emu "${@}"
rm -rf "$savesPath/.gaming"