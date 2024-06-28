#!/bin/bash


#SRM
SRM_toolPath="$HOME/Applications/EmuDeck/Steam ROM Manager.app"
SRM_userData_directory="darwin/configs/steam-rom-manager/userData"
SRM_userData_configDir="$HOME/Library/Application Support/steam-rom-manager/userData"
steam_input_templateFolder="$HOME/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS/controller_base/templates/"

#RetroArch
RetroArch_path="$HOME/Library/Application Support/RetroArch/"
RetroArch_configFile="$HOME/Library/Application Support/RetroArch/config/retroarch.cfg"
RetroArch_coreConfigFolders="$HOME/Library/Application Support/RetroArch/config"
RetroArch_cores="$HOME/Library/Application Support/RetroArch/cores"
RetroArch_remapsDir="$HOME/Library/Application Support/RetroArch/config/remaps"
RetroArch_overlaysPath="$HOME/Library/Application Support/RetroArch/overlays"
RetroArch_videoPath="$HOME/Applications/EmuDeck/RetroArch.app/Contents/Resources/filters/video"
RetroArch_coresURL="https://buildbot.libretro.com/nightly/apple/osx/${appleChip}/latest/"
RetroArch_coresExtension="dylib.zip"

#ESDE
ESDE_toolPath="$HOME/Applications/EmuDeck/ES-DE/ES-DE.dmg"
ESDE_toolPathExe="$HOME/Applications/EmuDeck/ES-DE/ES-DE.app" # Download
ESDE_addSteamInputFile="$EMUDECKGIT/darwin/configs/steam-input/emulationstation-de_controller_config.vdf"

#Pegasus
pegasus_emuPath="pegasus-frontend"
pegasus_path="$HOME/Library/Preferences/$pegasus_emuPath"
pegasus_dir_file="$pegasus_path/game_dirs.txt"
pegasus_config_file="$pegasus_path/settings.txt"