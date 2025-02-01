#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "mame" "org.mamedev.MAME" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
