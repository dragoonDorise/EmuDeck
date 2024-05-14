#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh 2>/dev/null
osascript -e 'display notification "Downloading saves" with title "CloudSync"'
cloud_sync_downloadEmuAll
open "$ESDE_toolPathExe" "${@}" && rm -rf "$savesPath/.gaming"
osascript -e 'display notification "Uploading saves" with title "CloudSync"'
cloud_sync_uploadEmuAll && osascript -e 'display notification "Saves uploaded" with title "CloudSync"' && rm -rf "$savesPath/.gaming"