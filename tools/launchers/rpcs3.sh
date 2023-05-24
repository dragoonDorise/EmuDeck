#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu rpcs3
/usr/bin/flatpak run net.rpcs3.RPCS3 "${@}"
cloud_sync_uploadEmu rpcs3