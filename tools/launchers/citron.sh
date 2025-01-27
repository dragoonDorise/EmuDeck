#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "citron" "citron" "${@}"
rm -rf "$savesPath/.gaming"