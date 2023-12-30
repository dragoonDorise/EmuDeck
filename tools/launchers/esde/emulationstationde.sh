#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmuAll && cloud_sync_startService
"$toolsPath/EmulationStation-DE.AppImage" "${@}"
rm -rf "$savesPath/.gaming"