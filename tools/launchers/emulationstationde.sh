#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu esde
$toolsPath/EmulationStation-DE-x64_SteamDeck.AppImage
rclone_uploadEmu esde