#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "esde"
"$ESDE_toolPath" "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";