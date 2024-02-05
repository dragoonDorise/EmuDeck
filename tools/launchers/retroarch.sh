#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "retroarch"
/usr/bin/flatpak run org.libretro.RetroArch "${@}"
rm -rf "$savesPath/.gaming"