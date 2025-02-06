#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "duckstation" "org.duckstation.DuckStation" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
