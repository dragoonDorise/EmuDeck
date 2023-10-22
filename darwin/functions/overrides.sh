#!/bin/bash
#We set the proper sed
PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
appleChip=$(uname -m)

#Override Vars
SRM_toolPath="Applications/Steam ROM Manager.app"
RetroArch_configFile="$HOME/Library/Application Support/RetroArch/config/retroarch.cfg"
RetroArch_coreConfigFolders="$HOME/Library/Application Support/RetroArch/config"
RetroArch_cores="$HOME/Library/Application Support/RetroArch/cores"
RetroArch_path="$HOME/Library/Application Support/RetroArch"
RetroArch_coresURL="https://buildbot.libretro.com/nightly/apple/osx/${appleChip}/latest/"
RetroArch_coresExtension="dylib.zip"
ESDE_toolPath="$HOME/Application/EmulationStation Desktop Edition.app"
ESDE_addSteamInputFile="$EMUDECKGIT/darwin/configs/steam-input/emulationstation-de_controller_config.vdf"
steam_input_templateFolder="$HOME/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS/controller_base/templates/"
SRM_userData_directory="darwin/configs/steam-rom-manager/userData"
SRM_userData_configDir="$HOME/Library/Application Support/steam-rom-manager/userData"

Pegasus_emuPath="pegasus-frontend"
Pegasus_path="$HOME/Library/Preferences/$Pegasus_emuPath"
Pegasus_dir_file="$Pegasus_path/game_dirs.txt"
Pegasus_config_file="$Pegasus_path/settings.txt"

source "$EMUDECKGIT/darwin/functions/overrides/configEmuFP.sh"
source "$EMUDECKGIT/darwin/functions/overrides/helperFunctions.sh"
source "$EMUDECKGIT/darwin/functions/overrides/emuDeckESDE.sh"
source "$EMUDECKGIT/darwin/functions/overrides/installEmuAI.sh"
source "$EMUDECKGIT/darwin/functions/overrides/installToolAI.sh"
source "$EMUDECKGIT/darwin/functions/overrides/emuDeckRetroArch.sh"
source "$EMUDECKGIT/darwin/functions/overrides/emuDeckPegasus.sh"
