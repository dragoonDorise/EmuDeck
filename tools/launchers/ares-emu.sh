#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
cd $biosPath
emulatorInit "ares" "dev.ares.ares" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
