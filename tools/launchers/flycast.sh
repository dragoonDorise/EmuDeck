#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "flycast"
/usr/bin/flatpak run org.flycast.Flycast "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";