#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "ppsspp" "org.ppsspp.PPSSPP" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
