#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "ppsspp" "ppsspp" "${@}"
rm -rf "$savesPath/.gaming"