#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "RMG"
/usr/bin/flatpak run com.github.Rosalie241.RMG "${@}"
rm -rf "$savesPath/.gaming"