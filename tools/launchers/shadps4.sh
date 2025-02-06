#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "shadps4" "net.shadps4.shadPS4" "" "Shadps4-qt*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
