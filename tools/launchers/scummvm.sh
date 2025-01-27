#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "scummvm" "scummvm" "${@}"
rm -rf "$savesPath/.gaming"