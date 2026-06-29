#!/usr/bin/env bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "dolphin"
flatpak run org.DolphinEmu.dolphin-emu "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
