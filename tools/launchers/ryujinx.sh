#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "ryujinx" "org.ryujinx.Ryujinx" "$emusFolder/publish" "Ryujinx.sh" "--" "${@}"
rm -rf "$savesPath/.gaming"
