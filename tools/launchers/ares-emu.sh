#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
cd $biosPath
emulatorInit "ares"
/usr/bin/flatpak run dev.ares.ares "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
