#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "yuzu" "yuzu" "${@}"
rm -rf "$savesPath/.gaming"