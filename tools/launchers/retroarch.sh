#!/bin/bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "retroarch"
/usr/bin/flatpak run org.libretro.RetroArch $netplayCMD "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";