#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "mgba" "io.mgba.mGBA" "" "mGBA*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
