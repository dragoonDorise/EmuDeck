#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "citra" "citra-qt" "${@}"
rm -rf "$savesPath/.gaming"