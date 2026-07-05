#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "RMG"
/usr/bin/flatpak run com.github.Rosalie241.RMG "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";