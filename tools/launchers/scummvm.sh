#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "scummvm"
/usr/bin/flatpak run org.scummvm.ScummVM "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";