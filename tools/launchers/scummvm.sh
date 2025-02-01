#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "scummvm" "org.scummvm.ScummVM" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
