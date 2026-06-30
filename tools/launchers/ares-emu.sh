#!/usr/bin/env bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
cd $biosPath
emulatorInit "ares"
flatpak run dev.ares.ares "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
