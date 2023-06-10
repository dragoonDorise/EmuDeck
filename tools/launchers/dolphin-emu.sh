#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu dolphin
/usr/bin/flatpak run org.DolphinEmu.dolphin-emu "${@}"
cloud_sync_uploadEmu dolphin