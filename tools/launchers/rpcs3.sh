#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "rpcs3"
/usr/bin/flatpak run net.rpcs3.RPCS3 "${@}"
rm -rf "$savesPath/.gaming"