#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu citra
/usr/bin/flatpak run org.citra_emu.citra "${@}"
cloud_sync_uploadEmu citra