#!/bin/bash





#
##
## Pid Lock...
##
#
devMode=$1
#We force the UI mode if we don't get any parameter for legacy installations
if [ -z "$2" ]; then
	uiMode='zenity'
else
	uiMode="$2"
fi


mkdir -p "$HOME/emudeck"
PIDFILE="$HOME/emudeck/install.pid"


if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE")
  ps -p "$PID" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "Process already running"
    exit 1
  else
    ## Process not found assume not running
    echo $$ > "$PIDFILE"
    if [ $? -ne 0 ]; then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  echo $$ > "$PIDFILE"
  if [ $? -ne 0 ]; then
    echo "Could not create PID file"
    exit 1
  fi
fi

function finish {
  echo "Script terminating. Exit code $?"
  finished=true
  rm "$MSG"
  killall zenity
}
trap finish EXIT


#
##
## Init... This code is needed for both Zenity and non Zenity modes
##
#


#Clean up previous installations
rm ~/emudek.log 2>/dev/null # This is emudeck's old log file, it's not a typo!
rm -rf ~/dragoonDoriseTools

#Creating log file
LOGFILE="$HOME/emudeck/emudeck.log"

mv "${LOGFILE}" "$HOME/emudeck/emudeck.last.log" #backup last log

echo "${@}" > "${LOGFILE}" #might as well log out the parameters of the run
exec > >(tee "${LOGFILE}") 2>&1
date "+%Y.%m.%d-%H:%M:%S %Z"
#Mark if this not a fresh install
FOLDER="$HOME/emudeck/"
if [ -d "$FOLDER" ]; then
	echo "" > "$HOME/emudeck/.finished"
fi
sleep 1
SECONDTIME="$HOME/emudeck/.finished"


#
##
## set backend location
##
# I think this should just be in the source, so there's one spot for initialization. hrm, no i'm wrong. Here is best.
EMUDECKGIT="$HOME/emudeck/backend"

#
##
echo 'Downloading files...'
##
#

#
##
## Branch to download
##
#

case $devMode in
	"BETA") 	branch="beta" 		;;
	"beta") 	branch="beta" 		;;
	"DEV") 		branch="dev" 		;;  
	"dev") 		branch="dev" 		;;
	*) 			branch="main" 		;;
esac	

echo $branch > "$HOME/emudeck/branch.txt"

if [[ "$uiMode" == 'zenity' || "$uiMode" == 'whiptail' ]]; then
	#We create all the needed folders for installation
	if [[ ! -e $EMUDECKGIT/.git/config ]]; then
		mkdir -p "$EMUDECKGIT"
	
		#Cloning EmuDeck files
		git clone https://github.com/dragoonDorise/EmuDeck.git "$EMUDECKGIT"
	fi
	
	git status "$EMUDECKGIT" --porcelain
	if [[ ! $noPull == true ]]; then
		cd "$EMUDECKGIT"
		git fetch origin  && git checkout origin/$branch  &&	git reset --hard origin/$branch && git clean -ffdx
		
	fi
fi


#
##
## UI Selection
##	
#


if [ "$uiMode" == 'zenity' ]; then
	
	source "$EMUDECKGIT/zenity-setup.sh"
	
elif [ "$uiMode" == 'whiptail' ]; then

	source "$EMUDECKGIT/whiptail-setup.sh"
	
else	
	echo "Electron UI"	
	#App Image detection & launch so older user can update just using the same old .desktop
	# if [[ ! -e "~/Applications/EmuDeck.AppImage" ]]; then
	# 	mkdir -p ~/Applications
	# 	curl -L "$(curl -s https://api.github.com/repos/EmuDeck/emudeck-electron/releases/latest | grep -E 'browser_download_url.*AppImage' | cut -d '"' -f 4)" > ~/Applications/EmuDeck.AppImage && chmod +x ~/Applications/EmuDeck.AppImage && kill -15 $(pidof emudeck) && ~/Applications/EmuDeck.AppImage && exit
	# fi
	#Nova fix'
fi


#
##
## Start of installation
##	
#




source "$EMUDECKGIT/functions/all.sh"

createFolders

echo "Current Settings: "
cat "$emuDecksettingsFile"



#
#Environment Check
#
echo ""
echo "Env Details: "
getEnvironmentDetails
testRealDeck

#this sets up the settings file with defaults, in case they don't have a new setting we've added.
#also echos them all out so they are in the log.
echo "Setup Settings File: "
createUpdateSettingsFile	

#Support for non-holo based OS's
#Only on Zenity for now
if [ "$uiMode" == 'zenity' ]; then
	if [[ $isRealDeck == false ]]; then
		echo "OS_setupPrereqsArch"
		OS_setupPrereqsArch
	fi
fi
#setup Proton-Launch.sh
#because this path gets updated by sed, we really should be installing it every time and allowing it to be updated every time. In case the user changes their path.
cp "$EMUDECKGIT/tools/proton-launch.sh" "${toolsPath}/proton-launch.sh"
chmod +x "${toolsPath}/proton-launch.sh"

#ESDE Installation
if [ $doInstallESDE == "true" ]; then
	echo "install esde"
	ESDE_install		
fi
#SRM Installation
if [ $doInstallSRM == "true" ]; then
	echo "install srm"
	SRM_install
fi
#Emulators Installation
if [ "$doInstallPCSX2" == "true" ]; then
	echo "install pcsx2"
	PCSX2_install
fi
if [ "$doInstallPCSX2QT" == "true" ]; then	
	echo "install pcsx2Qt"
	PCSX2QT_install
fi
if [ $doInstallPrimeHacks == "true" ]; then
	echo "install primehack"
	Primehack_install
fi
if [ $doInstallRPCS3 == "true" ]; then
	echo "install rpcs3"
	RPCS3_install
fi
if [ $doInstallCitra == "true" ]; then
	echo "install Citra"
	Citra_install
fi
if [ $doInstallDolphin == "true" ]; then
	echo "install Dolphin"	
	Dolphin_install
fi
if [ $doInstallDuck == "true" ]; then
	echo "DuckStation_install"
	DuckStation_install
fi
if [ $doInstallRA == "true" ]; then
	echo "RetroArch_install"
	RetroArch_install	
fi
if [ $doInstallPPSSPP == "true" ]; then
	echo "PPSSPP_install"
	PPSSPP_install	
fi
if [ $doInstallYuzu == "true" ]; then	
	echo "Yuzu_install"
	Yuzu_install
fi
if [ $doInstallRyujinx == "true" ]; then	
	echo "Ryujinx_install"
	Ryujinx_install
fi
if [ $doInstallMAME == "true" ]; then	
	echo "MAME_install"
	MAME_install
fi
if [ $doInstallXemu == "true" ]; then
	echo "Xemu_install"
	Xemu_install
fi
if [ $doInstallCemu == "true" ]; then
	echo "Cemu_install"
	Cemu_install
fi

#Xenia - We need to install Xenia after creating the Roms folders!
if [ "$doInstallXenia" == "true" ]; then
	echo "Xenia_install"
	Xenia_install
fi

#Steam RomManager Config

if [ "$doSetupSRM" == "true" ]; then
	echo "SRM_init"
	SRM_init
fi

#ESDE Config
if [ "$doSetupESDE" == "true" ]; then
	echo "ESDE_init"
	ESDE_update
fi	

#Emus config
#setMSG "Configuring Steam Input for emulators.." moved to emu install


setMSG "Configuring emulators.."

if [ "$doSetupRA" == "true" ]; then
	echo "RetroArch_init"
	RetroArch_init
fi
if [ "$doSetupPrimeHacks" == "true" ]; then
	echo "Primehack_init"
	Primehack_init
fi
if [ "$doSetupDolphin" == "true" ]; then
	echo "Dolphin_init"
	Dolphin_init
fi
if [ "$doSetupPCSX2" == "true" ]; then
	echo "PCSX2_init"
	PCSX2_init
fi
if [ "$doSetupPCSX2QT" == "true" ]; then
	echo "PCSX2QT_init"
	PCSX2QT_init
fi
if [ "$doSetupRPCS3" == "true" ]; then
	echo "RPCS3_init"
	RPCS3_init
fi
if [ "$doSetupCitra" == "true" ]; then
	echo "Citra_init"
	Citra_init
fi
if [ "$doSetupDuck" == "true" ]; then
	echo "DuckStation_init"
	DuckStation_init
fi
if [ "$doSetupYuzu" == "true" ]; then
	echo "Yuzu_init"
	Yuzu_init
fi
if [ "$doSetupRyujinx" == "true" ]; then
	echo "Ryujinx_init"
	Ryujinx_init
fi
if [ "$doSetupPPSSPP" == "true" ]; then
	echo "PPSSPP_init"
	PPSSPP_init
fi
if [ "$doSetupXemu" == "true" ]; then
	echo "Xemu_init"
	Xemu_init
fi
if [ "$doSetupMAME" == "true" ]; then
	echo "MAME_init"
	MAME_init
fi
#Proton Emus
if [ "$doSetupCemu" == "true" ]; then
	echo "Cemu_init"
	Cemu_init
fi
if [ "$doSetupXenia" == "true" ]; then
	echo "Xenia_init"
	Xenia_init
fi



#Fixes repeated Symlink for older installations
# Yuzu_finalize move into update / init to clean up install script



#
##
##End of installation
##
#




##
##
## Customizations.
##
##


#RA Bezels	
RetroArch_setBezels #needs to change

#ESDE_applyTheme "$esdeTheme" should apply in the init, from the setting

#RA AutoSave	
if [ "$RAautoSave" == true ]; then
	RetroArch_autoSaveOn
else
	RetroArch_autoSaveOff
fi	


# Old bezels and widescreen modes
if [ "$uiMode" == 'zenity' ]; then
	
	#Old Widescreen hacks
	if [ "$duckWide" == true ]; then	
		DuckStation_wideScreenOn
	else
		DuckStation_wideScreenOff
	fi
	if [ "$PCSX2QTWide" == true ]; then	
		PCSX2QT_wideScreenOn
	else
		PCSX2QT_wideScreenOff
	fi
	if [ "$DolphinWide" == true ]; then
		Dolphin_wideScreenOn
	else
		Dolphin_wideScreenOff
	fi
	if [ "$XemuWide" == true ]; then
		Xemu_wideScreenOn
	else
		Xemu_wideScreenOff
	fi
	if [ "$DreamcastWide" == true ]; then
		RetroArch_Flycast_wideScreenOn
	else
		RetroArch_Flycast_wideScreenOff
	fi
	
	#RA SNES Aspect Ratio
	RetroArch_setSNESAR #needs to change

else

	#
	#New Aspect Ratios
	#
	
	#Sega Games
		#Master System
		#Genesis
		#Sega CD
		#Sega 32X
	
	case $arSega in
  	"32")	 
		RetroArch_mastersystem_ar32
		RetroArch_genesis_ar32
		RetroArch_segacd_ar32
	  	RetroArch_sega32x_ar32	
		;;  
  	*)
		RetroArch_mastersystem_ar43
		RetroArch_genesis_ar43
	  	RetroArch_segacd_ar43
	  	RetroArch_sega32x_ar43
	  	if [ "$RABezels" == true ]; then	
	  		RetroArch_mastersystem_bezelOn
	  		RetroArch_genesis_bezelOn
	  		RetroArch_segacd_bezelOn
	  		RetroArch_sega32x_bezelOn
		fi
  	;;
	esac	
	
	#Snes and NES
	case $arSnes in
	  "87")
		  if [ "$RABezels" == true ]; then	
			  RetroArch_snes_bezelOn
		  fi
		RetroArch_snes_ar87
		RetroArch_nes_ar87
	  ;;
	  "32")
			RetroArch_snes_ar32
		  RetroArch_nes_ar32
		;;  
	  *)
		RetroArch_snes_ar43
		RetroArch_nes_ar43
		if [ "$RABezels" == true ]; then	
			RetroArch_snes_bezelOn
		fi
	  ;;
	esac
	
	# Classic 3D Games
		#Dreamcast
		#PSX
		#Nintendo 64
		#Saturn
		#Xbox
	if [ "$arClassic3D" == 169 ]; then		
		RetroArch_Beetle_PSX_HW_wideScreenOn
		DuckStation_wideScreenOn
		RetroArch_Flycast_wideScreenOn
		Xemu_wideScreenOn
		#"Bezels off"
		RetroArch_Flycast_bezelOff
		RetroArch_Beetle_PSX_HW_bezelOff
	else
		#"SET 4:3"
		RetroArch_Flycast_wideScreenOff
		RetroArch_Beetle_PSX_HW_wideScreenOff
		DuckStation_wideScreenOff
		Xemu_wideScreenOff
		#"Bezels on"
		if [ "$RABezels" == true ]; then	
			RetroArch_Flycast_bezelOn
			RetroArch_Beetle_PSX_HW_bezelOn
		fi			
	fi
	
	# GameCube
	if [ "$arDolphin" == 169 ]; then	
		Dolphin_wideScreenOn
	else
		Dolphin_wideScreenOff
	fi
	
fi


#
#New Shaders
#	
RetroArch_setShadersCRT
RetroArch_setShadersMAT

#RetroAchievments
if [ "$doRASignIn" == "true" ]; then
	RetroArch_retroAchievementsPromptLogin
	RetroArch_retroAchievementsSetLogin
	RetroArch_retroAchievementsOn
fi

if [ "$doRAEnable" == "true" ]; then
	RetroArch_retroAchievementsOn
fi

if [[ ! $branch == "main" ]]; then 
	if [[ $doSetupSaveSync == "true" ]]; then

		cloudProviders=()
		cloudProviders+=(1 "gdrive")
		cloudProviders+=(2 "dropbox")
		cloudProviders+=(3 "onedrive")
		cloudProviders+=(4 "box")
		cloudProviders+=(5 "nextcloud")

		syncProvider=$(zenity --list \
				--title="EmuDeck SaveSync Host" \
				--height=500 \
				--width=500 \
				--ok-label="OK" \
				--cancel-label="Exit" \
				--text="Choose the service you would like to use to host your cloud saves.\n\nKeep in mind they can take a fair amount of space.\n\nThis will open a browser window for you to sign into your chosen cloud provider." \
				--radiolist \
				--column="Select" \
				--column="Provider" \
				"${cloudProviders[@]}" 2>/dev/null)
		if [[ -n "$syncProvider" ]]; then
			SAVESYNC_install
			SAVESYNC_setup "$syncProvider"
		fi
	fi
fi 
#Sudo Required!

if [ "$expert" == "true" ]; then
	echo "$PASSWD" | sudo -v -S #refresh sudo cache
	if [ "$doInstallGyro" == "true" ]; then	
		Plugins_installSteamDeckGyroDSU
	fi

	if [ "$doInstallPowertools" == "true" ]; then
		Plugins_installPluginLoader
		Plugins_installPowerTools
	fi
fi

#Always install
BINUP_install
CHD_install

#
##
## Overrides for non Steam hardware...
##
#


#
#Fixes for 16:9 Screens
#

if [ "$(getScreenAR)" == 169 ];then
	nonDeck_169Screen		
fi

#Anbernic Win600 Special configuration
if [ "$(getProductName)" == "Win600" ];then
	nonDeck_win600		
fi



createDesktopIcons


#
##
##Validations
##
#

#PS Bios
checkPSBIOS

#Yuzu Keys & Firmware
FILE="$HOME/.local/share/yuzu/keys/prod.keys"
if [ -f "$FILE" ]; then
	echo -e "" 2>/dev/null
else
	if [ "$uiMode" != 'whiptail' ]; then
		text="$(printf "<b>Yuzu is not configured</b>\nYou need to copy your Keys and firmware to: \n${biosPath}/yuzu/keys\n${biosPath}\yuzu/firmware\n\nMake sure to copy your files inside the folders. <b>Do not overwrite them</b>")"
		zenity --error \
				--title="EmuDeck" \
				--width=400 \
				--text="${text}" 2>/dev/null
	else
		echo "Yuzu is not configured"
	fi
fi


# FILE="$HOME/.config/Ryujinx/system/prod.keys"
# if [ -f "$FILE" ]; then
# 	echo -e "" 2>/dev/null
# else
# 	if [ "$zenity" == true ]; then
# 	text="$(printf "<b>Ryujinx is not configured</b>\nYou need to copy your Keys to: \n${biosPath}/ryujinx/keys\n\nMake sure to copy your files inside the folders. <b>Do not overwrite them. You might need to install your firmware using the Ryujinx Install Firmware option inside the emulator</b>")"
# 	zenity --error \
# 			--title="EmuDeck" \
# 			--width=400 \
# 			--text="${text}" 2>/dev/null
# 	else
# 		echo "$text"
# 	fi
# fi

#EmuDeck updater on gaming Mode
mkdir -p "${toolsPath}/updater"
cp -v "$EMUDECKGIT/tools/updater/emudeck-updater.sh" "${toolsPath}/updater/"
chmod +x "${toolsPath}/updater/emudeck-updater.sh"

#RemotePlayWhatever
installEmuAI "RemotePlayWhatever"  "$(getReleaseURLGH "m4dEngi/RemotePlayWhatever" "AppImage")" 

#
# We mark the script as finished	
#
echo "" > "$HOME/emudeck/.finished"
echo "" > "$HOME/emudeck/.ui-finished"
echo "100" > "$HOME/emudeck/msg.log"
echo "# Installation Complete" >> "$HOME/emudeck/msg.log"
finished=true
rm "$PIDFILE"

if [ "$uiMode" == 'zenity' ]; then

	text="$(printf "<b>Done!</b>\n\nRemember to add your games here:\n<b>${romsPath}</b>\nAnd your Bios (PS1, PS2, Yuzu, Ryujinx) here:\n<b>${biosPath}</b>\n\nOpen Steam Rom Manager on your Desktop to add your games to your SteamUI Interface.\n\nThere is a bug in RetroArch that if you are using Bezels you can not set save configuration files unless you close your current game. Use overrides for your custom configurations or use expert mode to disabled them\n\nIf you encounter any problem please visit our Discord:\n<b>https://discord.gg/b9F7GpXtFP</b>\n\nTo Update EmuDeck in the future, just run this App again.\n\nEnjoy!")"
	
	zenity --question \
		 	--title="EmuDeck" \
		 	--width=450 \
		 	--ok-label="Open Steam Rom Manager" \
		 	--cancel-label="Exit" \
		 	--text="${text}" 2>/dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		kill -15 "$(pidof steam)"
		"${toolsPath}/srm/Steam-ROM-Manager.AppImage"
		zenity --question \
		 	--title="EmuDeck" \
		 	--width=350 \
		 	--text="Return to Game Mode?" \
		 	--ok-label="Yes" \
		 	--cancel-label="No" 2>/dev/null
		ans2=$?
		if [ $ans2 -eq 0 ]; then
			qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout
		fi
		exit
	else
		exit
		echo -e "Exit" 2>/dev/null
	fi
	
elif [ "$uiMode" == 'whiptail' ]; then
	echo "Finished on Whiptail"
	sleep 9999
fi