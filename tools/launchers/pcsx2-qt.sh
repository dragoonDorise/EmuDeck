#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "pcsx2" "net.pcsx2.PCSX2" "" "pcsx2-Qt*.AppImage" "--" ${@}
rm -rf "$savesPath/.gaming"
