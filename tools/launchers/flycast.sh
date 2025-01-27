#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "flycast" "flycast"  "${@}"
/usr/bin/flatpak run org.flycast.Flycast "${@}"