#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "mgba" "mGBA" "${@}"
rm -rf "$savesPath/.gaming"
