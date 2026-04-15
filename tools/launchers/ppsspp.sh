#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "ppsspp"
/usr/bin/flatpak run org.ppsspp.PPSSPP "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";