#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "rpcs3" "rpcs3" "${@}"
rm -rf "$savesPath/.gaming"
