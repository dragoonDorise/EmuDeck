#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "xemu"
/usr/bin/flatpak run app.xemu.xemu "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"; 