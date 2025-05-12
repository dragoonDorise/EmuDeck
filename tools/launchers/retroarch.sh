#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "retroarch"
/usr/bin/flatpak run org.libretro.RetroArch $netplayCMD "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";