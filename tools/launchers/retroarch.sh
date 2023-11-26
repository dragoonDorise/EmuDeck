#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "retroarch" && cloud_sync_startService
/usr/bin/flatpak run org.libretro.RetroArch "${@}"
rm -rf "$savesPath/.gaming"