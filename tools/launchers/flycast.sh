#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "flycast" "org.flycast.Flycast" "" "" "--" "${@}"
rm -rf "$savesPath/.gaming"
