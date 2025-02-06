#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "retroarch" "org.libretro.RetroArch" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
