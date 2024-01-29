#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "duckstation"
/usr/bin/flatpak run org.duckstation.DuckStation "${@}"
rm -rf "$savesPath/.gaming"