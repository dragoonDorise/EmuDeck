#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
#. "$HOME/.config/EmuDeck/backend/tools/rom-parser.sh"
cloud_sync_downloadEmuAll && cloud_sync_startService
$HOME/.config/EmuDeck/Emulators/pegasus-fe "${@}"
rm -rf "$savesPath/.gaming"
