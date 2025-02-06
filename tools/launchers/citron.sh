#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "citron" "citron" "" "citron*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
