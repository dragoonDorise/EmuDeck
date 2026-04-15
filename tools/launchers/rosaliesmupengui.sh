#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "RMG"
/usr/bin/flatpak run com.github.Rosalie241.RMG "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";