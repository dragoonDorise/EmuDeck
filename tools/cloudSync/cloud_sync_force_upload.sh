#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_uploadEmuAll | zenity --progress --pulsate --title "Uploading Saved games" --width 600 --auto-close --no-cancel 2>/dev/null
rm -rf "$savesPath/.gaming"