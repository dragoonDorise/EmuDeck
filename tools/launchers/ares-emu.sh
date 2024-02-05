#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "ares" && cloud_sync_startService

cd $biosPath

emulatorInit "ares"
/usr/bin/flatpak run dev.ares.ares "${@}"
rm -rf "$savesPath/.gaming"
