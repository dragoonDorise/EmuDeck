#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "flycast"
/usr/bin/flatpak run org.flycast.Flycast "${@}"
rm -rf "$savesPath/.gaming"