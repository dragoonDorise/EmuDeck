#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "mame" && cloud_sync_startService
/usr/bin/flatpak run org.mamedev.MAME "${@}"
rm -rf "$savesPath/.gaming"