#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "duckstation"
/usr/bin/flatpak run org.duckstation.DuckStation "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";