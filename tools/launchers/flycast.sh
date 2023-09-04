#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "flycast" && cloud_sync_startService
/usr/bin/flatpak run org.flycast.Flycast "${@}"
rm -rf "$savesPath/.gaming"