#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "primehack" "io.github.shiiion.primehack" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
