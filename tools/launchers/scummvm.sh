#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "scummvm"
/usr/bin/flatpak run org.scummvm.ScummVM "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";