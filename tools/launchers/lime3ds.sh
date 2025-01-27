#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "lime3ds" "lime3ds-gui" "${@}"
rm -rf "$savesPath/.gaming"