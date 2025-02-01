#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "Cemu" "info.cemu.Cemu" "" "Cemu*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
