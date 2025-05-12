#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "mame"
/usr/bin/flatpak run org.mamedev.MAME "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";