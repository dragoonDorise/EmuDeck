#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "melonds"
/usr/bin/flatpak run net.kuribo64.melonDS "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";