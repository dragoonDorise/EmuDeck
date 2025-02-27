#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
cd $biosPath
emulatorInit "ares"
/usr/bin/flatpak run dev.ares.ares "${@}"
rm -rf "$savesPath/.gaming"
