#!/bin/bash

#
##
## Branch to download
##
#

branch="dev"
echo $branch > "$HOME/.config/EmuDeck/branch.txt"

#VARS
EMUDECKGIT="$HOME/.config/EmuDeck/backend"
emuDecksettingsFile="$HOME/emudeck/settings.sh"



#Functions

function setSetting() {
	local var=$1
	local new_val=$2

	settingExists=$(grep -rw "$emuDecksettingsFile" -e "$var")
	if [[ $settingExists == '' ]]; then
		#insert setting to end
		echo "variable not found in settings. Adding $var=$new_val to $emuDecksettingsFile"
		sed -i -e '$a\'"$var=$new_val" "$emuDecksettingsFile"
	elif [[ ! $settingExists == '' ]]; then
		echo "Old value $settingExists"
			if [[ $settingExists == "$var=$new_val" ]]; then
				echo "Setting unchanged, skipping"
			else
				changeLine "$var=" "$var=$new_val" "$emuDecksettingsFile"
			fi
	fi
	#Update values
	# shellcheck source=settings.sh
	source "$emuDecksettingsFile"
}

setDefaults(){

	setSetting expert false
	setSetting system SteamOS
	setSetting doSetupRA true
	setSetting doSetupDolphin true
	setSetting doSetupPCSX2QT true
	setSetting doSetupRPCS3 true
	setSetting doSetupCitra true
	setSetting doSetupYuzu true
	setSetting doSetupmelonDS true
	setSetting doSetupCemu true
	setSetting doSetupPrimehack true
	setSetting doSetupDuck true
	setSetting doSetupRyujinx true
	setSetting doSetupXemu true
	setSetting doSetupPPSSPP true
	setSetting doSetupXenia false
	setSetting doSetupMAME true
	setSetting doSetupRMG false
	setSetting doSetupScummVM true
	setSetting doSetupVita3K true
	setSetting doSetupESDE true
	setSetting doInstallRA true
	setSetting doSetupMGBA true
	setSetting doInstallRPCS3 true
	setSetting doInstallYuzu true
	setSetting doInstallCitra true
	setSetting doInstallPCSX2QT true
	setSetting doInstallDolphin true
	setSetting doInstallRyujinx false
	setSetting doInstallmelonDS true
	setSetting doInstallRMG true
	setSetting doInstallCemu true
	setSetting doSetupSRM true
	setSetting doInstallPrimeHack true
	setSetting doInstallDuck true
	setSetting doInstallPPSSPP true
	setSetting doInstallXemu true
	setSetting doInstallXenia false
	setSetting doInstallMAME false
	setSetting doInstallScummVM true
	setSetting doInstallGyro false
	setSetting doInstallVita3K true
	setSetting doInstallSRM true
	setSetting doInstallCHD true
	setSetting doInstallPowertools false
	setSetting doInstallMGBA false
	setSetting doInstallHomeBrewGames false
	setSetting doInstallESDE true
	setSetting arSega 43
	setSetting arSnes 43
	setSetting arDolphin 43
	setSetting arClassic3D 43
	setSetting RABezels true
	setSetting RAautoSave false
	setSetting duckWide false
	setSetting DolphinWide false
	setSetting DreamcastWide false
	setSetting BeetleWide false
	setSetting pcsx2QTWide false
	setSetting emulationPath $HOME/Emulation
	setSetting romsPath $HOME/Emulation/roms
	setSetting toolsPath $HOME/Emulation/tools
	setSetting biosPath $HOME/Emulation/bios
	setSetting storagePath $HOME/Emulation/storage
	setSetting savesPath $HOME/Emulation/saves
	setSetting ESDEscrapData $HOME/Emulation/tools/downloaded_media
	setSetting RAHandHeldShader false
	setSetting RAHandClassic2D false
	setSetting RAHandClassic3D false
	setSetting esdeTheme EPICNOIR
	setSetting doSelectWideScreen false
	setSetting doRASignIn false
	setSetting doRAEnable false
	setSetting doSelectEmulators false
	setSetting doESDEThemePicker false
	setSetting doResetEmulators false
	setSetting XemuWide false
	setSetting achievementsHardcore false
	setSetting cloud_sync_provider false
	setSetting cloud_sync_status false
	setSetting dolphinResolution 720P
	setSetting rclone_provider false
	setSetting duckstationResolution 720P
	setSetting pcsx2Resolution 720P
	setSetting yuzuResolution 720P
	setSetting ppssppResolution 720P
	setSetting rpcs3Resolution 720P
	setSetting ryujinxResolution 720P
	setSetting xemuResolution 720P
	setSetting emuGBA multiemulator
	setSetting emuMAME multiemulator
	setSetting xeniaResolution 720P
	setSetting emuNDS melonds
	setSetting emuN64 ra
	setSetting emuMULTI ra
	setSetting emuPSP ppsspp
	setSetting emuPSX duckstation
	setSetting emuSCUMMVM scummvm
	setSetting emuDreamcast multiemulator

}

#We create all the needed folders for installation
if [[ ! -e $EMUDECKGIT/.git/config ]]; then
	mkdir -p "$EMUDECKGIT"

	#Cloning EmuDeck files
	git clone --depth 1 --no-single-branch https://github.com/dragoonDorise/EmuDeck.git "$EMUDECKGIT"
	git checkout $branch
else
	cd "$EMUDECKGIT"
	git fetch origin  && git checkout origin/$branch  && git reset --hard origin/$branch && git clean -ffdx
fi


#Default settings per system on Easy mode
setDefaults

#
# UI Start
#

# Welcome, Quick or custom?
source "$EMUDECKGIT"/whiptail/WelcomePage.sh

if [ $expert == 'false' ]; then
	cp "$EMUDECKGIT/settings.sh" "$emuDecksettingsFile"
fi

# Location
source "$EMUDECKGIT"/whiptail/RomStoragePage.sh



#
## Custom mode Questions
#

if [ $expert == 'true' ]; then

	# Emulators
	source $EMUDECKGIT/whiptail/EmulatorSelectorPage.sh

	# if [ $second == true ]; then
	# 	# Overwrite configuration?
	# 	source "$EMUDECKGIT"/whiptail/EmulatorConfigurationPage.sh
	# fi

	# Retroachievements
	#source "$EMUDECKGIT"/whiptail/RAAchievementsPage.sh

	# Bezels
	source "$EMUDECKGIT"/whiptail/RABezelsPage.sh

	#  if [ $deviceAR != 43 ]; then
	# 	 # AR Sega Classic
		 source "$EMUDECKGIT"/whiptail/AspectRatioSegaPage.sh
	#
	# 	 # AR SNES + NES
		  source "$EMUDECKGIT"/whiptail/AspectRatioSNESPage.sh
	#
	# 	# AR 3D Classics
	# 	source "$EMUDECKGIT"/whiptail/AspectRatio3DPage.sh
	#
	# 	# AR Gamecube
	# 	source "$EMUDECKGIT"/whiptail/AspectRatioDolphinPage.sh
	# fi

	# LCD Shader Handhelds
	#source "$EMUDECKGIT"/whiptail/ShadersHandheldsPage.sh

	# CRT Shader Handhelds
	#source "$EMUDECKGIT"/whiptail/Shaders2DPage.sh

	# Frontend
	source "$EMUDECKGIT"/whiptail/PegasusInstallPage.sh

	# Pegasus Theme
	if [ $doInstallPegasus == true ]; then
		source "$EMUDECKGIT"/whiptail/PegasusThemePage.sh
	fi

fi



# Installation...


. "$EMUDECKGIT/setup.sh"
