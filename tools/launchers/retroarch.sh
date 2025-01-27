#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "retroarch" "RetroArch" "${@}"
rm -rf "$savesPath/.gaming"