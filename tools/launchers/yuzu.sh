#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "yuzu" "org.yuzu_emu.yuzu" "" "yuzu-ea*.AppImage" "yuzu*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
