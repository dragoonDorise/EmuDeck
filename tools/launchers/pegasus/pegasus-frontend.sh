#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
. "$HOME/.config/EmuDeck/backend/tools/rom-parser.sh"
cloud_sync_downloadEmuAll && cloud_sync_startService
/usr/bin/flatpak run org.pegasus_frontend.Pegasus "${@}"
rm -rf "$savesPath/.gaming"
