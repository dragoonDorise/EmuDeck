#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "Vita3k" "Vita3k" "${@}"
rm -rf "$savesPath/.gaming"
