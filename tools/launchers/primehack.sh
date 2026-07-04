#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "primehack"
/usr/bin/flatpak run io.github.shiiion.primehack "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";