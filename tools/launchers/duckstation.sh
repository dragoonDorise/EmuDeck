#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "duckstation" "duckstation" "${@}"
rm -rf "$savesPath/.gaming"