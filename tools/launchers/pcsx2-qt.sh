#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "pcsx2" "pcsx2-Qt" "${@}"
rm -rf "$savesPath/.gaming"
