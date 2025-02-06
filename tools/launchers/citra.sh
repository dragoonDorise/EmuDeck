#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "citra" "org.citra_emu.citra" "" "citra-qt*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
