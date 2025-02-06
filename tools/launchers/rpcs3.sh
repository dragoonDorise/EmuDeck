#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "rpcs3" "net.rpcs3.RPCS3" "" "rpcs3*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
