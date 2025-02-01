#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "suyu" "suyu" "" "suyu*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
