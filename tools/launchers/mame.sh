#!/usr/bin/env bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "mame"
flatpak run org.mamedev.MAME "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
