#!/bin/bash
#source $HOME/.config/EmuDeck/backend/functions/all.sh
#cloud_sync_downloadEmu "retroarch" && cloud_sync_startService
"$HOME/Applications/RetroArch.app" "${@}"
#rm -rf "$savesPath/.gaming"