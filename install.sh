#!/bin/bash

#
##
## Pid Lock...
##
#
mkdir -p $HOME/emudeck
PIDFILE=$HOME/emudeck/install.pid

if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "Process already running"
    exit 1
  else
    ## Process not found assume not running
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo "Could not create PID file"
    exit 1
  fi
fi


#
##
## Init... This code is needed for both Zenity and non Zenty modes
##
#

#Clean up previous installations
rm ~/emudek.log 2>/dev/null # This is emudeck's old log file, it's not a typo!
rm -rf ~/dragoonDoriseTools

#Creating log file
echo "" > ~/emudeck/emudeck.log
LOGFILE=~/emudeck/emudeck.log
exec > >(tee ${LOGFILE}) 2>&1

#Mark if this not a fresh install
FOLDER=~/emudeck/
if [ -d "$FOLDER" ]; then
	echo "" > ~/emudeck/.finished
fi
sleep 1
SECONDTIME=~/emudeck/.finished
EMUDECKGIT="$HOME/emudeck/git/EmuDeck"

# Seeting up the progress Bar for the rest of the installation
finished=false
echo "0" > ~/emudeck/msg.log
echo "# Installing EmuDeck" >> ~/emudeck/msg.log
MSG=~/emudeck/msg.log
(	
	while [ $finished == false ]
	do 
		  cat $MSG		    
		  if grep -q "100" "$MSG"; then
			  finished=true
			break
		  fi
							  
	done &
) |
zenity --progress \
  --title="Installing EmuDeck" \
  --text="Installing EmuDeck..." \
  --percentage=0 \
  --no-cancel \
  --pulsate \
  --auto-close \
  --width=300 \ &

if [ "$?" = -1 ] ; then
	zenity --error \
	--text="Update canceled."
fi


	
#
##
## Branch to download
##
#
devMode=$1
case $devMode in
  "BETA")
	branch="beta"
  ;;
  "DEV")
	  branch="dev"
	;;  
  "EmuReorg")
	  branch="EmuReorg"
	;;  
  *)
	branch="main"
  ;;
esac	

echo $branch > ~/branch.txt

#
##
## Downloading files...
##
#

#We create all the needed folders for installation
mkdir -p "$EMUDECKGIT"

#Cloning EmuDeck files
git clone https://github.com/dragoonDorise/EmuDeck.git "$EMUDECKGIT"
if [ ! -z "$devMode" ]; then
	cd "$EMUDECKGIT"
	git checkout "$branch" 
fi

#
##
## Do we need Zenity?...
##
#
if [ -z $2 ]; then
	zenity=true
else
	zenity=$2
fi



if [ $zenity == true ]; then

	#This part of the code is where all the settings are created

	
	
	#Test if we have a successful clone	
	if [ -d "$EMUDECKGIT" ]; then
		echo -e "Files Downloaded!"
	clear
	cat $EMUDECKGIT/logo.ans
	version=$(cat $EMUDECKGIT/version.md)
	echo -e "${BOLD}EmuDeck ${version}${NONE}"
	echo -e ""
	cat $EMUDECKGIT/latest.md
	
	else
		echo -e ""
		echo -e "We couldn't download the needed files, exiting in a few seconds"
		echo -e "Please close this window and try again in a few minutes"
		sleep 999999
		exit
	fi
	
	#
	##
	## EmuDeck is installed, start setting up stuff
	##
	#
	
	#Functions and settings, this code is repeated outside of this conditional, remember to 
	source "$EMUDECKGIT/functions/all.sh"
	#Check for config file
	SETTINGSFILE="$HOME/emudeck/settings.sh"
	if [ -f "$SETTINGSFILE" ]; then
		source "$EMUDECKGIT/settings.sh"
		else
		cp "$EMUDECKGIT/settings.sh" "$SETTINGSFILE"
	fi

	
	#
	## Splash screen
	#
	
	latest=$(cat $EMUDECKGIT/latest.md)	
	if [ -f "$SECONDTIME" ]; then
		 text="$(printf "<b>Hi, this is the changelog of the new features added in this version</b>\n\n${latest}")"
		 width=1000
	else
		text="$(printf "<b>Welcome to EmuDeck!</b>")"
		width=300
	fi 
	 zenity --info \
	--title="EmuDeck" \
	--width="${width}" \
	--text="${text}" 2>/dev/null
		
	#
	#Hardware Check for Holo Users
	#
	if [[ "$(cat /sys/devices/virtual/dmi/id/product_name)" =~ Jupiter ]]; then
		isRealDeck=true
	else
		isRealDeck=false
	fi
	
	#
	# Initialize locations
	#
	locationTable=()
	locationTable+=(TRUE "Internal" "$HOME") #always valid
	
	#built in SD Card reader
	if [ -b "/dev/mmcblk0p1" ]; then	
		#test if card is writable and linkable
		sdCardFull="$(findmnt -n --raw --evaluate --output=target -S /dev/mmcblk0p1)"
		echo "SD Card found; testing $sdCardFull for validity."
		sdValid=$(testLocationValid "SD" $sdCardFull)
		echo "SD Card at $sdCardFull is valid? Return val: $sdValid"
		if [[ $sdValid == "valid" ]]; then
			locationTable+=(FALSE "SD Card" "$sdCardFull") 
		fi
	fi
	
	#
	# Installation mode selection
	#
	
	text="`printf "<b>Hi!</b>\nDo you want to run EmuDeck on Easy or Expert mode?\n\n<b>Easy Mode</b> takes care of everything for you, it is an unattended installation.\n\n<b>Expert mode</b> gives you a bit more of control on how EmuDeck configures your system like giving you the option to install PowerTools or keep your custom configurations per Emulator"`"
	zenity --question \
			 --title="EmuDeck" \
			 --width=250 \
			 --ok-label="Expert Mode" \
			 --cancel-label="Easy Mode" \
			 --text="${text}" 2>/dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		setSetting expert true
		echo "Mode selected: Expert"
		locationTable+=(FALSE "Custom" "CUSTOM") #in expert mode we'll allow the user to pick an arbitrary place.
	else
		setSetting expert false
		echo "Mode selected: Easy"
	fi
	
	#
	#Storage Selection
	#
	
	if [[ ${#locationTable[@]} -gt 3 ]]; then # -gt 3 because there's 3 entries per row.
		destination=$(zenity --list \
		--title="Where would you like Emudeck to be installed?" \
		--radiolist \
		--width=400 --height=225 \
		--column="" --column="Install Location" --column="value" \
		--hide-column=3 --print-column=3 \
			"${locationTable[@]}"  2>/dev/null)
		ans=$?
		if [ $ans -eq 0 ]; then
			echo "Storage: ${destination}"
		else
			echo "No storage choice made"
			exit
		fi
	else
		destination="$HOME"
	fi
	
	if [[ $destination == "CUSTOM" ]]; then
		destination=$(zenity --file-selection --directory --title="Select a destination for the Emulation directory." 2>/dev/null)
		if [[ $destination != "CUSTOM" ]]; then
			echo "Storage: ${destination}"
			customValid=$(testLocationValid "Custom" "${destination}")
	
			if [[ $customValid != "valid" ]]; then
				echo "Valid location not chosen. Exiting"
				exit
			fi
	
		else
			echo "User didn't choose. Exiting."
			exit
		fi
	fi
	
	#New paths based on where the user picked.
	setSetting emulationPath "${destination}/Emulation/"
	setSetting romsPath "${destination}/Emulation/roms/"
	setSetting toolsPath "${destination}/Emulation/tools/"
	setSetting biosPath "${destination}/Emulation/bios/"
	setSetting savesPath "${destination}/Emulation/saves/"
	setSetting storagePath "${destination}/Emulation/storage/"
	setSetting ESDEscrapData "${destination}/Emulation/tools/downloaded_media/"

	#Folder creation... This code is repeated outside of this if for the no zenity mode
	mkdir -p "$emulationPath"
	mkdir -p "$toolsPath"launchers 
	mkdir -p "$savesPath"
	mkdir -p "$romsPath"
	mkdir -p "$storagePath"
	mkdir -p "$biosPath"yuzu
	
	##Generate rom folders
	setMSG "Creating roms folder in $destination"
	
	sleep 3
	rsync -r --ignore-existing $EMUDECKGIT/roms/ "$romsPath" 
	#End repeated code	
	
	#
	# Start of Expert mode configuration
	# The idea is that Easy mode is unatended, so everything that's out
	# out of the ordinary has to had its flag enabled/disabled on Expert mode
	#	
	
	if [ $expert == "true" ]; then
		echo "Expert mode begin"
		
			#one entry per expert mode feature
			table=()
			table+=(TRUE "CHDScript" "Install the latest version of our CHD conversion script?")
			table+=(TRUE "PowerTools" "Install Power Tools for CPU control? (password required)")
			table+=(TRUE "SteamGyro" "Setup the SteamDeckGyroDSU for gyro control (password required)")
			table+=(TRUE "updateSRM" "Install/Update Steam Rom Manager? Customizations will not be reset.")
			table+=(TRUE "updateESDE" "Install/Update Emulation Station DE? Customizations and scrapes will not be reset.")
			table+=(TRUE "selectEmulators" "Select the emulators to install.")
			table+=(TRUE "selectEmulatorConfig" "Customize the emulator configuration reset. (note: Fixes will be skipped if boxes are unchecked)")
			table+=(TRUE "selectRABezels" "Turn on Bezels for Retroarch?")
			table+=(TRUE "selectRAAutoSave" "Turn on Retroarch AutoSave/Restore state?")
			table+=(TRUE "snesAR" "SNES 8:7 Aspect Ratio? (unchecked is 4:3)")
			table+=(TRUE "selectWideScreen" "Customize Emulator Widescreen Selection?")
			table+=(TRUE "setRAEnabled" "Enable Retroachievments in Retroarch?")
			table+=(TRUE "setRASignIn" "Change RetroAchievements Sign in?")
			table+=(TRUE "doESDEThemePicker" "Choose your EmulationStation-DE Theme?")		
			#table+=(TRUE "doXboxButtons" "Should facebutton letters match between Nintendo and Steamdeck? (default is matched location)")
	
			declare -i height=(${#table[@]}*40)
	
			expertModeFeatureList=$(zenity  --list --checklist --width=1000 --height=${height} \
			--column="Select?"  \
			--column="Features"  \
			--column="Description" \
			--hide-column=2 \
			"${table[@]}" 2>/dev/null)
			echo "user selected: $expertModeFeatureList"
			#set flags to true for selected expert mode features
			if [[ "$expertModeFeatureList" == *"CHDScript"* ]]; then
				setSetting doInstallCHD true
			fi
			if [[ "$expertModeFeatureList" == *"PowerTools"* ]]; then
				setSetting doInstallPowertools true
			fi
			if [[ "$expertModeFeatureList" == *"SteamGyro"* ]]; then
				setSetting doInstallGyro true
			fi
			if [[ "$expertModeFeatureList" == *"updateSRM"* ]]; then
				setSetting doSetupSRM true
			fi
			if [[ "$expertModeFeatureList" == *"updateESDE"* ]]; then
				setSetting doInstallESDE true
			fi
			if [[ "$expertModeFeatureList" == *"selectEmulators"* ]]; then
				setSetting doSelectEmulators true
			fi
			if [[ "$expertModeFeatureList" == *"selectEmulatorConfig"* ]]; then
				setSetting doResetEmulators true
			fi
			if [[ "$expertModeFeatureList" == *"selectRABezels"* ]]; then
				setSetting RABezels true
			fi
			if [[ "$expertModeFeatureList" == *"selectRAAutoSave"* ]]; then
				setSetting RAautoSave true
			fi
			if [[ "$expertModeFeatureList" == *"snesAR"* ]]; then
				setSetting SNESAR 43	
			fi
			if [[ "$expertModeFeatureList" == *"selectWideScreen"* ]]; then
				setSetting doSelectWideScreen true			
			fi
			if [[ "$expertModeFeatureList" == *"setRASignIn"* ]]; then
				setSetting doRASignIn true
			fi
			if [[ "$expertModeFeatureList" == *"setRAEnable"* ]]; then
				setSetting doRAEnable true
			fi
			if [[ "$expertModeFeatureList" == *"doESDEThemePicker"* ]]; then
				setSetting doESDEThemePicker true
			fi	
			
	
			if [[ $doInstallPowertools == "true" || $doInstallGyro == "true" || $isRealDeck == "false" ]]; then
				hasPass=$(passwd -S $(whoami) | awk -F " " '{print $2}')
				if [[ ! $hasPass == "P" ]]; then
					text="`printf "<b>Password not set.</b>\n Please set one now in the terminal.\nYou will not see text entry in the terminal for your password. This is normal.\nOnce set, you will be prompted to enter it in a new window."`"
					zenity --error \
					--title="EmuDeck" \
					--width=400 \
					--text="${text}" 2>/dev/null
					passwd 
				fi
				PASSWD="$(zenity --password --title="Enter Deck User Password (not Steam account!)" 2>/dev/null)"
				echo $PASSWD | sudo -v -S
				ans=$?
				if [[ $ans == 1 ]]; then
					#incorrect password
					PASSWD="$(zenity --password --title="Password was incorrect. Try again. (Did you remember to set a password for linux before running this?)" 2>/dev/null)"
					echo $PASSWD | sudo -v -S
					ans=$?
					if [[ $ans == 1 ]]; then
							text="`printf "<b>Password not accepted.</b>\n Expert mode tools which require a password will not work. Disabling them."`"
							zenity --error \
							--title="EmuDeck" \
							--width=400 \
							--text="${text}" 2>/dev/null
							setSetting doInstallPowertools false
							setSetting doInstallGyro false
					fi
				fi
			fi
			
		
		if [[ $doSelectEmulators == "true" ]]; then
			
			emuTable=()
			emuTable+=(TRUE "Multiple" "RetroArch")
			emuTable+=(TRUE "Metroid Prime" "PrimeHack")
			emuTable+=(TRUE "PS2" "PCSX2")
			emuTable+=(TRUE "PS3" "RPCS3")
			emuTable+=(TRUE "3DS" "Citra")
			emuTable+=(TRUE "GC/Wii" "Dolphin")
			emuTable+=(TRUE "PSX" "Duckstation")
			emuTable+=(TRUE "PSP" "PPSSPP")
			emuTable+=(TRUE "Switch" "Yuzu")
			emuTable+=(TRUE "WiiU" "Cemu")
			emuTable+=(TRUE "XBox" "Xemu")
			#if we are in beta / dev install, allow Xenia. Still false by default though. Will only work on expert mode, and explicitly turned on.
			if [[ $branch=="beta" || $branch=="dev" ]]; then
				emuTable+=(FALSE "Xbox360" "Xenia")
			fi
			
			#Emulator selector
			text="`printf "What emulators do you want to install?"`"
			emusToInstall=$(zenity --list \
					--title="EmuDeck" \
					--height=500 \
					--width=250 \
					--ok-label="OK" \
					--cancel-label="Exit" \
					--text="${text}" \
					--checklist \
					--column="Select" \
					--column="System" \
					--column="Emulator" \
					--print-column=3 \
					"${emuTable[@]}" 2>/dev/null)
			ans=$?
			
			if [ $ans -eq 0 ]; then
				echo "Emu Install selected: $emusToInstall"
				if [[ "$emusToInstall" == *"RetroArch"* ]]; then
					setSetting doInstallRA true
				fi
				if [[ "$emusToInstall" == *"PrimeHack"* ]]; then
					setSetting doInstallPrimeHacks true
				fi
				if [[ "$emusToInstall" == *"PCSX2"* ]]; then
					setSetting doInstallPCSX2 true
				fi
				if [[ "$emusToInstall" == *"RPCS3"* ]]; then
					setSetting doInstallRPCS3 true
				fi
				if [[ "$emusToInstall" == *"Citra"* ]]; then
					setSetting doInstallCitra true
				fi
				if [[ "$emusToInstall" == *"Dolphin"* ]]; then
					setSetting doInstallDolphin true
				fi
				if [[ "$emusToInstall" == *"Duckstation"* ]]; then
					setSetting doInstallDuck true
				fi
				if [[ "$emusToInstall" == *"PPSSPP"* ]]; then
					setSetting doInstallPPSSPP true
				fi
				if [[ "$emusToInstall" == *"Yuzu"* ]]; then
					setSetting doInstallYuzu true
				fi
				if [[ "$emusToInstall" == *"Cemu"* ]]; then
					setSetting doInstallCemu true
				fi
				if [[ "$emusToInstall" == *"Xemu"* ]]; then
					setSetting doInstallXemu true
				fi
				if [[ "$emusToInstall" == *"Xenia"* ]]; then
					setSetting doInstallXenia true
				fi
				#if [[ "$emusToInstall" == *"MelonDS"* ]]; then
				#	doInstallMelon=true
				#fi
			
			
			else
				exit
			fi
		fi
		
	
		if [[ $doSelectWideScreen == "true" ]]; then
			#Emulators screenHacks
			emuTable=()
			emuTable+=(TRUE "Dolphin")
			emuTable+=(TRUE "Duckstation")
			emuTable+=(TRUE "RA-BeetlePSX")
			emuTable+=(TRUE "RA-Flycast")
			emuTable+=(TRUE "Xemu")
	
			text="`printf "Selected Emulators will use WideScreen Hacks"`"
			wideToInstall=$(zenity --list \
						--title="EmuDeck" \
						--height=500 \
						--width=250 \
						--ok-label="OK" \
						--cancel-label="Exit" \
						--text="${text}" \
						--checklist \
						--column="Widescreen?" \
						--column="Emulator" \
						"${emuTable[@]}"  2>/dev/null)
			ans=$?	
			if [ $ans -eq 0 ]; then
				echo "Widescreen choices: $wideToInstall"
				if [[ "$wideToInstall" == *"Duckstation"* ]]; then
					setSetting duckWide true
				else
					setSetting duckWide false
				fi
				if [[ "$wideToInstall" == *"Dolphin"* ]]; then
					setSetting DolphinWide true
				else
					setSetting DolphinWide false
				fi
				if [[ "$wideToInstall" == *"RA-Flycast"* ]]; then
					setSetting DreamcastWide true
				else
					setSetting DreamcastWide false
				fi		
				if [[ "$wideToInstall" == *"BeetlePSX"* ]]; then
					setSetting BeetleWide true
				else
					setSetting BeetleWide false
				fi				
				if [[ "$wideToInstall" == *"Xemu"* ]]; then
					setSetting XemuWide true
				else
					setSetting XemuWide false
				fi			
				
			else		
				exit		
			fi			
		fi
		#We mark we've made a custom configuration for future updates
		echo "" > ~/emudeck/.custom
		
		if [[ $doResetEmulators == "true" ]]; then
			# Configuration that only appplies to previous users
			if [ -f "$SECONDTIME" ]; then
	
				installString='Updating'
	
				emuTable=()
				emuTable+=(TRUE "RetroArch")
				emuTable+=(TRUE "PrimeHack")
				emuTable+=(TRUE "PCSX2")
				emuTable+=(TRUE "RPCS3")
				emuTable+=(TRUE "Citra")
				emuTable+=(TRUE "Dolphin")
				emuTable+=(TRUE "Duckstation")
				emuTable+=(TRUE "PPSSPP")
				emuTable+=(TRUE "Yuzu")
				emuTable+=(TRUE "Cemu")
				emuTable+=(TRUE "Xemu")
				emuTable+=(TRUE "Steam Rom Manager")
				emuTable+=(TRUE "EmulationStation DE")
	
				text="`printf "<b>EmuDeck will reset the following Emulator's configurations by default.</b>\nWhich systems do you want <b>reset</b> to the newest version of the defaults?\nWe recommend you keep all of them checked so everything gets updated and known issues are fixed.\nIf you want to mantain any custom configuration on an emulator unselect its name from this list."`"
				emusToReset=$(zenity --list \
									--title="EmuDeck" \
									--height=500 \
									--width=250 \
									--ok-label="OK" \
									--cancel-label="Exit" \
									--text="${text}" \
									--checklist \
									--column="Reset?" \
									--column="Emulator" \
									"${emuTable[@]}"  2>/dev/null)
									ans=$?
				#Nova fix'								
				cat $EMUDECKGIT/logo.ans
				echo -e "EmuDeck ${version}"
				if [ $ans -eq 0 ]; then
					echo "Emulators to reinstall selected: $emusToReset"
					if [[ "$emusToReset" == *"RetroArch"* ]]; then
						setSetting doSetupRA true
					fi
					if [[ "$emusToReset" == *"PrimeHack"* ]]; then
						setSetting doSetupPrimeHacks true
					fi
					if [[ "$emusToReset" == *"PCSX2"* ]]; then
						setSetting doSetupPCSX2 true
					fi
					if [[ "$emusToReset" == *"RPCS3"* ]]; then
						setSetting doSetupRPCS3 true
					fi
					if [[ "$emusToReset" == *"Citra"* ]]; then
						setSetting doSetupCitra true
					fi
					if [[ "$emusToReset" == *"Dolphin"* ]]; then
						setSetting doSetupDolphin true
					fi
					if [[ "$emusToReset" == *"Duckstation"* ]]; then
						setSetting doSetupDuck true
					fi
					if [[ "$emusToReset" == *"PPSSPP"* ]]; then
						setSetting doSetupPPSSPP true
					fi
					if [[ "$emusToReset" == *"Yuzu"* ]]; then
						setSetting doSetupYuzu true
					fi
					if [[ "$emusToReset" == *"Cemu"* ]]; then
						setSetting doSetupCemu true
					fi
					if [[ "$emusToReset" == *"Xemu"* ]]; then
						setSetting doSetupXemu true
					fi
					if [[ "$emusToReset" == *"Xenia"* ]]; then
						setSetting doSetupXenia false #false until we add above
					fi
					#if [[ "$emusToReset" == *"MelonDS"* ]]; then
					#	setSetting doSetupMelonDS true
					#fi
					if [[ "$emusToReset" == *"Steam Rom Manager"* ]]; then
						setSetting doSetupSRM true
					fi
					if [[ "$emusToReset" == *"EmulationStation DE"* ]]; then
						setSetting doSetupESDE true
					fi
				
				
				else
					echo ""
				fi
				
			fi
		fi
	else
		#easy mode settings
		setSetting doInstallRA true
		setSetting doInstallDolphin true
		setSetting doInstallPCSX2 true
		setSetting doInstallRPCS3 true
		setSetting doInstallYuzu true
		setSetting doInstallCitra true
		setSetting doInstallDuck true
		setSetting doInstallCemu true
		setSetting doInstallXenia false
		setSetting doInstallPrimeHacks true
		setSetting doInstallPPSSPP true
		setSetting doInstallXemu true
		#doInstallMelon=true
	
		#widescreen off by default
		setSetting duckWide false
		setSetting DolphinWide false
		setSetting DreamcastWide false
		setSetting BeetleWide false
		setSetting XemuWide false	
	
	fi # end Expert if
	
	
	#Support for non-valve hardware.
	if [[ $isRealDeck == false ]]; then
		 setUpHolo
	fi

else
	#We only load functions and config when no Zenity selected
	source "$EMUDECKGIT"/functions/all.sh
	source ~/emudeck/settings.sh	
	
	#Folder creation... This code is repeated outside of this if for the yes zenity mode
	mkdir -p "$emulationPath"
	mkdir -p "$toolsPath"launchers 
	mkdir -p "$savesPath"
	mkdir -p "$romsPath"
	mkdir -p "$storagePath"
	mkdir -p "$biosPath"yuzu
	
	##Generate rom folders
	setMSG "Creating roms folder in $destination"
	
	sleep 3
	rsync -r --ignore-existing $EMUDECKGIT/roms/ "$romsPath" 
	#End repeated code	
fi


##
##
## End of Zenity configuration
##	
##


	
	
##
##
## Start of installation
##	
##
## First up - migrate things that need to move. Now in the update method.
#echo "begin migrations"
#doMigrations



#
## extra Binaries to path
#
export PATH="${EMUDECKGIT}/tools/binaries/:$PATH"
chmod +x "${EMUDECKGIT}/tools/binaries/xmlstarlet"



#setup Proton-Launch.sh
#because this path gets updated by sed, we really should be installing it every time and allowing it to be updated every time. In case the user changes their path.
cp $EMUDECKGIT/tools/proton-launch.sh "${toolsPath}"proton-launch.sh
chmod +x "${toolsPath}"proton-launch.sh

#ESDE Installation
if [ $doInstallESDE == "true" ]; then
	ESDE.install		
fi
	
#SRM Installation
if [ $doInstallSRM == "true" ]; then
	installSRM
fi

#Emulators Installation
if [ $doInstallPCSX2 == "true" ]; then	
	PCSX2.install
fi
if [ $doInstallPrimeHacks == "true" ]; then
	Primehack.install
fi
if [ $doInstallRPCS3 == "true" ]; then
	RPCS3.install
fi
if [ $doInstallCitra == "true" ]; then
	Citra.install
fi
if [ $doInstallDolphin == "true" ]; then
	Dolphin.install
fi
if [ $doInstallDuck == "true" ]; then
	DuckStation.install
fi
if [ $doInstallRA == "true" ]; then
	RetroArch.install	
fi
if [ $doInstallPPSSPP == "true" ]; then
	PPSSPP.install	
fi
if [ $doInstallYuzu == "true" ]; then	
	Yuzu.install
fi
if [ $doInstallXemu == "true" ]; then
	Xemu.install
fi
if [ $doInstallCemu == "true" ]; then
	Cemu.install
fi

#Xenia - We need to install Xenia after creating the Roms folders!
if [ $doInstallXenia == "true" ]; then
	setMSG "Installing Xenia"		
	FILE="${romsPath}xbox360/xenia.exe"	
	if [ -f "$FILE" ]; then
		echo "" 2>/dev/null
	else
		curl -L https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip --output "$romsPath"xbox360/xenia_master.zip 
		mkdir -p "$romsPath"xbox360/tmp
		unzip -o "$romsPath"xbox360/xenia_master.zip -d "$romsPath"xbox360/tmp 
		mv "$romsPath"xbox360/tmp/* "$romsPath"xbox360 
		rm -rf "$romsPath"xbox360/tmp 
		rm -f "$romsPath"xbox360/xenia_master.zip 		
	fi
	
fi

#Steam RomManager Config

if [ $doSetupSRM == "true" ]; then
	SRM.init
fi

#ESDE Config
if [ $doSetupESDE == "true" ]; then
	ESDE.init
fi	

#Emus config
setMSG "Configuring Steam Input for emulators.."
rsync -r $EMUDECKGIT/configs/steam-input/ ~/.steam/steam/controller_base/templates/

setMSG "Configuring emulators.."
echo -e ""
if [ $doSetupRA == "true" ]; then
	RetroArch.init
fi
if [ $doSetupPrimeHacks == "true" ]; then
	Primehack.init
fi
if [ $doSetupDolphin == "true" ]; then
	Dolphin.init
fi
if [ $doSetupPCSX2 == "true" ]; then
	PCSX2.init
fi
if [ $doSetupRPCS3 == "true" ]; then
	RPCS3.init
fi
if [ $doSetupCitra == "true" ]; then
	Citra.init
fi
if [ $doSetupDuck == "true" ]; then
	DuckStation.init
fi
if [ $doSetupYuzu == "true" ]; then
	Yuzu.init
fi
if [ $doSetupPPSSPP == "true" ]; then
	PPSSPP.init
fi
if [ $doSetupXemu == "true" ]; then
	Xemu.init
fi
#Proton Emus
if [ $doSetupCemu == "true" ]; then
	Cemu.init
fi
if [ $doSetupXenia == "true" ]; then
	echo "" 
	rsync -avhp $EMUDECKGIT/configs/xenia/ "$romsPath"/xbox360 
fi



#Fixes repeated Symlink for older installations
Yuzu.finalize



#
##
##End of installation
##
#


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
		
	text="`printf "<b>Yuzu is not configured</b>\nYou need to copy your Keys and firmware to: \n${biosPath}yuzu/keys\n${biosPath}yuzu/firmware\n\nMake sure to copy your files inside the folders. <b>Do not overwrite them</b>"`"
	zenity --error \
			--title="EmuDeck" \
			--width=400 \
			--text="${text}" 2>/dev/null
fi


##
##
## RetroArch Customizations.
##
##


#RA Bezels	
RABezels

#RA SNES Aspect Ratio
RASNES

#RA AutoSave	
RAautoSave



##
##
## Other Customizations.
##
##


#Widescreen hacks
setWide

#RetroAchievments
RAAchievment


if [ $doInstallCHD == "true" ]; then
	installCHD
fi

if [ $doInstallGyro == "true" ]; then	
	InstallGyro=$(bash <(curl -sL https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh))
	echo $(printf "$InstallGyro" )
fi


if [ $doInstallPowertools == "true" ]; then
	installPowerTools	
fi

if [ $branch == 'main' ];then
	createDesktopIcons
fi

installBinUp


# setMSG "Cleaning up downloaded files..."	
# rm -rf ~/dragoonDoriseTools	
clear

# We mark the script as finished	
echo "" > ~/emudeck/.finished
echo "" > ~/emudeck/.electron-finished
echo "100" > ~/emudeck/msg.log
echo "# Installation Complete" >> ~/emudeck/msg.log
finished=true
rm $PIDFILE

if [ $zenity == true ]; then

	text="`printf "<b>Done!</b>\n\nRemember to add your games here:\n<b>${romsPath}</b>\nAnd your Bios (PS1, PS2, Yuzu) here:\n<b>${biosPath}</b>\n\nOpen Steam Rom Manager on your Desktop to add your games to your SteamUI Interface.\n\nThere is a bug in RetroArch that if you are using Bezels you can not set save configuration files unless you close your current game. Use overrides for your custom configurations or use expert mode to disabled them\n\nIf you encounter any problem please visit our Discord:\n<b>https://discord.gg/b9F7GpXtFP</b>\n\nTo Update EmuDeck in the future, just run this App again.\n\nEnjoy!"`"
	
	zenity --question \
		 	--title="EmuDeck" \
		 	--width=450 \
		 	--ok-label="Open Steam Rom Manager" \
		 	--cancel-label="Exit" \
		 	--text="${text}" 2>/dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		kill -15 `pidof steam`
		cd ${toolsPath}/srm
		./Steam-ROM-Manager.AppImage
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

fi