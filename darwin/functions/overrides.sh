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

pegasus_emuPath="pegasus-frontend"
pegasus_path="$HOME/Library/Preferences/$pegasus_emuPath"
pegasus_dir_file="$pegasus_path/game_dirs.txt"
pegasus_config_file="$pegasus_path/settings.txt"

source "$EMUDECKGIT/darwin/functions/overrides/configEmuFP.sh"
source "$EMUDECKGIT/darwin/functions/overrides/helperFunctions.sh"
source "$EMUDECKGIT/darwin/functions/overrides/emuDeckESDE.sh"
source "$EMUDECKGIT/darwin/functions/overrides/installEmuAI.sh"
source "$EMUDECKGIT/darwin/functions/overrides/installToolAI.sh"
source "$EMUDECKGIT/darwin/functions/overrides/emuDeckRetroArch.sh"
source "$EMUDECKGIT/darwin/functions/overrides/emuDeckPegasus.sh"


ares_install(){
	echo "NYI"
}
BigPEmu_install(){
	echo "NYI"
}
Cemu_install(){
	echo "NYI"
}
CemuProton_install(){
	echo "NYI"
}
Citra_install(){
	echo "NYI"
}
CitraLegacy_install(){
	echo "NYI"
}
Dolphin_install(){
	echo "NYI"
}
DuckStation_install(){
	echo "NYI"
}
Flycast_install(){
	echo "NYI"
}
MAME_install(){
	echo "NYI"
}
MelonDS_install(){
	echo "NYI"
}
MGBA_install(){
	echo "NYI"
}
Model2_install(){
	echo "NYI"
}
PCSX2QT_install(){
	echo "NYI"
}
PPSSPP_install(){
	echo "NYI"
}
Primehack_install(){
	echo "NYI"
}
RMG_install(){
	echo "NYI"
}
RPCS3_install(){
	echo "NYI"
}
RPCS3Legacy_install(){
	echo "NYI"
}
Ryujinx_install(){
	echo "NYI"
}
ScummVM_install(){
	echo "NYI"
}
Supermodel_install(){
	echo "NYI"
}
Vita3K_install(){
	echo "NYI"
}
Xemu_install(){
	echo "NYI"
}
Xenia_install(){
	echo "NYI"
}
Yuzu_install(){
	echo "NYI"
}



BINUP_install(){
	echo "NYI"
}
CHD_install(){
	echo "NYI"
}
CloudBackup_install(){
	echo "NYI"
}
CloudSync_install(){
	echo "NYI"
}
CopyGames_install(){
	echo "NYI"
}
InstallHomebrewGames_install(){
	echo "NYI"
}
Migration_install(){
	echo "NYI"
}
Pegasus_install(){
	echo "NYI"
}
Plugins_install(){
	echo "NYI"
}
RemotePlayWhatever_install(){
	echo "NYI"
}


ares_init(){
	echo "NYI"
}
BigPEmu_init(){
	echo "NYI"
}
Cemu_init(){
	echo "NYI"
}
CemuProton_init(){
	echo "NYI"
}
Citra_init(){
	echo "NYI"
}
CitraLegacy_init(){
	echo "NYI"
}
Dolphin_init(){
	echo "NYI"
}
DuckStation_init(){
	echo "NYI"
}
Flycast_init(){
	echo "NYI"
}
MAME_init(){
	echo "NYI"
}
MelonDS_init(){
	echo "NYI"
}
MGBA_init(){
	echo "NYI"
}
Model2_init(){
	echo "NYI"
}
PCSX2QT_init(){
	echo "NYI"
}
PPSSPP_init(){
	echo "NYI"
}
Primehack_init(){
	echo "NYI"
}
RMG_init(){
	echo "NYI"
}
RPCS3_init(){
	echo "NYI"
}
RPCS3Legacy_init(){
	echo "NYI"
}
Ryujinx_init(){
	echo "NYI"
}
ScummVM_init(){
	echo "NYI"
}
Supermodel_init(){
	echo "NYI"
}
Vita3K_init(){
	echo "NYI"
}
Xemu_init(){
	echo "NYI"
}
Xenia_init(){
	echo "NYI"
}
Yuzu_init(){
	echo "NYI"
}