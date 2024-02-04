#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "ppsspp"
/usr/bin/flatpak run org.ppsspp.PPSSPP "${@}"
rm -rf "$savesPath/.gaming"