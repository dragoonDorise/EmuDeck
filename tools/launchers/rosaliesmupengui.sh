#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "RMG" "RMG" "${@}"
rm -rf "$savesPath/.gaming"