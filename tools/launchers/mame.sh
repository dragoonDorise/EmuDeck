#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu mame
/usr/bin/flatpak run org.mamedev.MAME "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"