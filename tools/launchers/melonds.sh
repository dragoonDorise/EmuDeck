#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "melonds"
/usr/bin/flatpak run net.kuribo64.melonDS "${@}"
rm -rf "$savesPath/.gaming"