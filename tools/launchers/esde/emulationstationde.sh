#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmuAll && cloud_sync_startService
"$ESDE_toolLocation/EmulationStation-DE.AppImage" "${@}"
rm -rf "$savesPath/.gaming"