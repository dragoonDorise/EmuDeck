#!/usr/bin/env bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "melonds"
flatpak run net.kuribo64.melonDS "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
