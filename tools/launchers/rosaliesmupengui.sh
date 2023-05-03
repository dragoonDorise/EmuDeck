#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu rmg
/usr/bin/flatpak run com.github.Rosalie241.RMG "${@}"
cloud_sync_uploadEmu rmg