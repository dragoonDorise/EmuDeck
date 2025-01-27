#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "mame" "MAME" "${@}"
rm -rf "$savesPath/.gaming"