#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "dolphin"
/usr/bin/flatpak run org.DolphinEmu.dolphin-emu "${@}"
rm -rf "$savesPath/.gaming"