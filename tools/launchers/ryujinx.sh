#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "ryujinx" "Ryujinx" "${@}"
rm -rf "$savesPath/.gaming"
