#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
cloud_sync_downloadESDE && cloud_sync_startService
"$ESDE_toolPath" "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";