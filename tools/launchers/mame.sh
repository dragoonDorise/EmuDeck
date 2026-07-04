#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "mame"
/usr/bin/flatpak run org.mamedev.MAME "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";