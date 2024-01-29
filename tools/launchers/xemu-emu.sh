#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "xemu"
/usr/bin/flatpak run app.xemu.xemu "${@}"
rm -rf "$savesPath/.gaming" 