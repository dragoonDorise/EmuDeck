#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
export LC_ALL="C" # this was originally in the launcher, so i kept it
emulatorInit "Vita3k" "Vita3k" "$emusFolder/Vita3K" "Vita3k" "--" "${@}"
rm -rf "$savesPath/.gaming"
