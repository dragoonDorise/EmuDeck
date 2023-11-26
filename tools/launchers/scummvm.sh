#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "scummvm" && cloud_sync_startService
/usr/bin/flatpak run org.scummvm.ScummVM "${@}"
rm -rf "$savesPath/.gaming"