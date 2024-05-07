#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "retroarch"
/usr/bin/flatpak run org.libretro.RetroArch $netplayCMD "${@}"
rm -rf "$savesPath/.gaming"