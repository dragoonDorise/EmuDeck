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



function createUpdateSettingsFile(){
	#!/bin/bash

	if [ ! -e "$emuDecksettingsFile" ]; then
		echo "#!/bin/bash"> "$emuDecksettingsFile"
	fi
	local defaultSettingsList=()
	defaultSettingsList+=("doInstallSRM=true")
	defaultSettingsList+=("doInstallRA=true")
	defaultSettingsList+=("doSetupDolphin=false")
	defaultSettingsList+=("doSetupmelonDS=false")
	defaultSettingsList+=("doInstallmelonDS=false")
	defaultSettingsList+=("doSetupRPCS3=false")
	defaultSettingsList+=("doSetupYuzu=false")
	defaultSettingsList+=("doSetupCitra=false")
	defaultSettingsList+=("doSetupDuck=false")
	defaultSettingsList+=("doSetupCemu=false")
	defaultSettingsList+=("doSetupXenia=false")
	defaultSettingsList+=("doSetupRyujinx=false")
	defaultSettingsList+=("doSetupMAME=false")
	defaultSettingsList+=("doSetupPrimehack=false")
	defaultSettingsList+=("doSetupPPSSPP=false")
	defaultSettingsList+=("doSetupXemu=false")
	defaultSettingsList+=("doSetupPCSX2QT=false")
	defaultSettingsList+=("doSetupScummVM=false")
	defaultSettingsList+=("doSetupVita3K=false")
	defaultSettingsList+=("doSetupRMG=false")
	defaultSettingsList+=("doSetupMGBA=false")
	defaultSettingsList+=("doSetupFlycast=false")
	defaultSettingsList+=("doInstallDolphin=false")
	defaultSettingsList+=("doInstallMAME=false")
	defaultSettingsList+=("doInstallRyujinx=false")
	defaultSettingsList+=("doInstallRPCS3=false")
	defaultSettingsList+=("doInstallYuzu=false")
	defaultSettingsList+=("doInstallCitra=false")
	defaultSettingsList+=("doInstallDuck=false")
	defaultSettingsList+=("doInstallCemu=false")
	defaultSettingsList+=("doInstallXenia=false")
	defaultSettingsList+=("doInstallPrimeHack=false")
	defaultSettingsList+=("doInstallPPSSPP=false")
	defaultSettingsList+=("doInstallXemu=false")
	defaultSettingsList+=("doInstallPCSX2QT=false")
	defaultSettingsList+=("doInstallScummVM=false")
	defaultSettingsList+=("doInstallVita3K=false")
	#defaultSettingsList+=("doInstallMelon=false")
	defaultSettingsList+=("doInstallMGBA=false")
	defaultSettingsList+=("doInstallFlycast=false")
	defaultSettingsList+=("doInstallCHD=false")
	defaultSettingsList+=("doInstallPowertools=false")
	defaultSettingsList+=("doInstallGyro=false")
	defaultSettingsList+=("doInstallHomeBrewGames=false")
	defaultSettingsList+=("installString='Installing'")

	tmp=$(mktemp)
	#sort "$emuDecksettingsFile" | uniq -u > "$tmp" && mv "$tmp" "$emuDecksettingsFile"

	cat "$emuDecksettingsFile" | awk '!unique[$0]++' > "$tmp" && mv "$tmp" "$emuDecksettingsFile"
	for setting in "${defaultSettingsList[@]}"
		do
			local settingName=$(cut -d "=" -f1 <<< "$setting")
			local settingVal=$(cut -d "=" -f2 <<< "$setting")
			if grep -r "^${settingName}=" "$emuDecksettingsFile" &>/dev/null; then
				echo "Setting: $settingName found. CurrentValue: $(getSetting "$settingName")"
				setSetting "$settingName" "$settingVal"
			else
				echo "Setting: $settingName NOT found. adding to $emuDecksettingsFile with default value: $settingVal"
				setSetting "$settingName" "$settingVal"
			fi
		done

}