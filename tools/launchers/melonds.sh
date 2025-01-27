#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "melonds" "melonDS" "${@}"
rm -rf "$savesPath/.gaming"