#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "shadps4" "shadps4" "${@}"
rm -rf "$savesPath/.gaming"
