#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "primehack"
/usr/bin/flatpak run io.github.shiiion.primehack "${@}"
rm -rf "$savesPath/.gaming"