#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "primehack"
/usr/bin/flatpak run io.github.shiiion.primehack "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";