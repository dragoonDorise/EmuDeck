#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
#. "$emudeckBackend/tools/rom-parser.sh"
cloud_sync_downloadEmuAll && cloud_sync_startService
$pegasusFolder/pegasus-fe "${@}"
rm -rf "$savesPath/.gaming"
