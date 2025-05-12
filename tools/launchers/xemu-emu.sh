#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "xemu"
/usr/bin/flatpak run app.xemu.xemu "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming"; 