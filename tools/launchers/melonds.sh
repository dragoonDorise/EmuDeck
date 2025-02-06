#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "melonds" "net.kuribo64.melonDS" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
