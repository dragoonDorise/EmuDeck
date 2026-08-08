#!/usr/bin/env bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit
emulatorInit "dolphin" "${@}"
flatpak run org.DolphinEmu.dolphin-emu "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
