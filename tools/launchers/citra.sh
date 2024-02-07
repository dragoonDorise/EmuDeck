#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "citra"
/usr/bin/flatpak run org.citra_emu.citra "${@}"
rm -rf "$savesPath/.gaming"