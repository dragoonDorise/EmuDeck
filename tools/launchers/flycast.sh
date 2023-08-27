#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu flycast
/usr/bin/flatpak run org.flycast.Flycast "${@}"
cloud_sync_uploadEmu flycast
