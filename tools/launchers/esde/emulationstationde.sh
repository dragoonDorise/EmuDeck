#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmuAll
$toolsPath/EmulationStation-DE-x64_SteamDeck.AppImage "${@}" & cloud_sync_startService
rm -rf "$savesPath/.watching"