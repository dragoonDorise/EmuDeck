#!/bin/bash
#source $HOME/.config/EmuDeck/backend/functions/all.sh
#cloud_sync_downloadEmu "retroarch" && cloud_sync_startService
open "$HOME/Applications/EmuDeck/RetroArch.app" --args "${@}"
#rm -rf "$savesPath/.gaming"