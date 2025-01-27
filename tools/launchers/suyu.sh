#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
param="${@}"
param=$(echo $param | sed -e 's/^/"/' -e 's/$/"/')
emulatorInit "suyu" "suyu" "$param"
rm -rf "$savesPath/.gaming"