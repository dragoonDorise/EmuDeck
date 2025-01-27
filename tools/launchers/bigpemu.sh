#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "BigPEmu" "bigPEmu" "${@}"
rm -rf "$savesPath/.gaming"
