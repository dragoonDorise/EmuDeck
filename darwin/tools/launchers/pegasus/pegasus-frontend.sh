#!/bin/bash
#source $HOME/.config/EmuDeck/backend/functions/all.sh
#cloud_sync_downloadEmuAll && cloud_sync_startService
source $HOME/.config/EmuDeck/backend/tools/rom-parser.sh
open "/Applications/Pegasus.app" --args "${@}"

#rm -rf "$savesPath/.gaming"
