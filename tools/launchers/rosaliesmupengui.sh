#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "RMG" "com.github.Rosalie241.RMG" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
