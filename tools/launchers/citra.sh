#!/bin/sh
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu citra
/usr/bin/flatpak run org.citra_emu.citra
rclone_uploadEmu citra