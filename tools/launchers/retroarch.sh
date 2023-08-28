#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu retroarch
/usr/bin/flatpak run org.libretro.RetroArch "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"