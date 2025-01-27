#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "xemu" "xemu" "${@}"
rm -rf "$savesPath/.gaming"