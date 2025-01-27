#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "retroarch" "retroarch" "${@}"
rm -rf "$savesPath/.gaming"