#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmuAll
open "$ESDE_toolPathExe" "${@}"
rm -rf "$savesPath/.gaming"
cloud_sync_uploadEmuAll