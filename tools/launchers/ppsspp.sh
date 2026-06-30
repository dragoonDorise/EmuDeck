#!/usr/bin/env bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "ppsspp"
flatpak run org.ppsspp.PPSSPP "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
