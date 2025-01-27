#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "Cemu" "Cemu" "${@}"
rm -rf "$savesPath/.gaming"