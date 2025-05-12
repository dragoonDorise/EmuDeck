#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
#. "$emudeckBackend/tools/rom-parser.sh"
cloud_sync_downloadEmuAll && cloud_sync_startService
$pegasusFolder/pegasus-fe "${@}"
cloud_sync_uploadForced
rm -rf "$savesPath/.gaming";
