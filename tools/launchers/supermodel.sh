#!/bin/sh
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "supermodel" "com.supermodel3.Supermodel" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
