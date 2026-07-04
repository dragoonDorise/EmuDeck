#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "xenia"

XENIA="$HOME/Applications/xenia_canary_linux.AppImage"

"$XENIA" "${@}"

cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"