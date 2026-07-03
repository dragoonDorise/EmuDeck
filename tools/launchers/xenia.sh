#!/bin/bash
# xenia.sh

. "$HOME/.config/EmuDeck/backend/functions/all.sh"

emulatorInit "xenia"

XENIA="$HOME/Applications/xenia_canary_linux.AppImage"

"$XENIA" "${@}"

cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"