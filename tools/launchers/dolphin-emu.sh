#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "dolphin" "dolphin-emu" "${@}"
rm -rf "$savesPath/.gaming"