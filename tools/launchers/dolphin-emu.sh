#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "dolphin"
/usr/bin/flatpak run org.DolphinEmu.dolphin-emu "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";