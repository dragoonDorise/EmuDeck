#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "ppsspp"
/usr/bin/flatpak run org.ppsspp.PPSSPP "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";