#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "citra" && cloud_sync_startService
/usr/bin/flatpak run org.citra_emu.citra "${@}"
rm -rf "$savesPath/.gaming"