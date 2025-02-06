#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "lime3ds" "io.github.lime3ds.Lime3DS" "" "lime3ds-gui*.AppImage" "--" "${@}"
rm -rf "$savesPath/.gaming"
