#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh 2>/dev/null
cloud_sync_downloadEmuAll
open -W -a "$ESDE_toolPathExe" "${@}" && rm -rf "$savesPath/.gaming"
cloud_sync_uploadEmuAll
rm -rf "$savesPath/.gaming"