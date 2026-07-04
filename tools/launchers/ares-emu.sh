#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
cd $biosPath
emulatorInit "ares"
/usr/bin/flatpak run dev.ares.ares "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
