#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "ares"
/usr/bin/flatpak run dev.ares.ares "${@}"
rm -rf "$savesPath/.gaming"
