#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu esde
$toolsPath/EmulationStation-DE-x64_SteamDeck.AppImage "${@}"
cloud_sync_uploadEmu esde