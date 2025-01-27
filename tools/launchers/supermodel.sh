#!/bin/sh
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
param="${@}"
param=$(echo "$param" | sed "s|'||g")
emulatorInit "supermodel" "supermodel3" "${param}"
rm -rf "$savesPath/.gaming"