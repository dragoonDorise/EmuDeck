#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmuAll | zenity --progress --pulsate --title "Downloading Saved games" --width 600 --auto-close --no-cancel 2>/dev/null
rm -rf "$savesPath/.gaming"