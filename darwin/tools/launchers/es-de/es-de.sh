#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
#cloud_sync_downloadEmuAll && cloud_sync_startService
open "$ESDE_toolPathExe" "${@}"
rm -rf "$savesPath/.gaming"