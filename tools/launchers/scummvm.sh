#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "scummvm"
/usr/bin/flatpak run org.scummvm.ScummVM "${@}"
rm -rf "$savesPath/.gaming"