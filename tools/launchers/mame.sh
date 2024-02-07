#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "mame"
/usr/bin/flatpak run org.mamedev.MAME "${@}"
rm -rf "$savesPath/.gaming"