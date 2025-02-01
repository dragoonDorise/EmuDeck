#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "dolphin" "org.DolphinEmu.dolphin-emu" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"