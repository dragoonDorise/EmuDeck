#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "primehack" "primehack" "${@}"
rm -rf "$savesPath/.gaming"