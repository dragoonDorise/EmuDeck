#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "melonds"
/usr/bin/flatpak run net.kuribo64.melonDS "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";