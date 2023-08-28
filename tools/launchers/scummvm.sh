#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu scummvm
/usr/bin/flatpak run org.scummvm.ScummVM "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"