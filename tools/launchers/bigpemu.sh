#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "BigPEmu" "com.richwhitehouse.BigPEmu" "$emusFolder/BigPEmu" "bigpemu" "--" "${@}"
rm -rf "$savesPath/.gaming"
