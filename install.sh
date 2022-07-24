#!/bin/bash

#
##
## Pid Lock...
##
#
mkdir -p "$HOME/emudeck"
PIDFILE="$HOME/emudeck/install.pid"

devMode=$1
echo $devMode

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

#
##
## Do we need Zenity?... Anything in the second param will skip zenity
##
#
if [ -z "$2" ]; then
	zenity=true
else
	zenity="$2"
fi



#Clean up previous installations
rm ~/emudek.log 2>/dev/null # This is emudeck's old log file, it's not a typo!
rm -rf ~/dragoonDoriseTools

#Creating log file
mv "$HOME/emudeck/emudeck.log" "$HOME/emudeck/emudeck.last.log" #backup last log
echo "${@}" > "$HOME/emudeck/emudeck.log" #might as well log out the parameters of the run
LOGFILE="$HOME/emudeck/emudeck.log"
exec > >(tee "${LOGFILE}") 2>&1
date "+%Y.%m.%d-%H:%M:%S %Z"
#Mark if this not a fresh install
FOLDER="$HOME/emudeck/"
if [ -d "$FOLDER" ]; then
	echo "" > "$HOME/emudeck/.finished"
fi
sleep 1
SECONDTIME="$HOME/emudeck/.finished"


# Seeting up the progress Bar for the rest of the installation

if [[ $zenity == true ]]; then
	finished=false
	MSG=~/emudeck/msg.log
	echo "0" > "$MSG"
	echo "# Installing EmuDeck" >> "$MSG"

	(	
		while [ $finished == false ]
		do 
			cat "$MSG"   
			if grep -q "100" "$MSG"; then
				finished=true
				break
			fi
			# sleep 10
		done
	) 	|	zenity --progress \
			--title="Installing EmuDeck" \
			--text="Installing EmuDeck..." \
			--percentage=0 \
			--no-cancel \
			--pulsate \
			--auto-close \
			--width=300  2>/dev/null &

	if [ "$?" == -1 ] ; then
		zenity --error \
		--text="Update canceled." 2>/dev/null
	fi
fi


	

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
	"DEV") 		branch="dev" 		;;  
	"EmuReorg") branch="EmuReorg" 	;;  
	*) 			branch="main" 		;;
esac	

echo $branch > "$HOME/emudeck/branch.txt"



#We create all the needed folders for installation
if [[ ! -e $EMUDECKGIT ]]; then
	mkdir -p "$EMUDECKGIT"

	#Cloning EmuDeck files
	git clone https://github.com/dragoonDorise/EmuDeck.git "$EMUDECKGIT"
fi

git status "$EMUDECKGIT" --porcelain
if [[ ! $noPull == true ]]; then
	git fetch origin
	git reset --hard origin/$branch
	git clean -ffdx
fi



#
##
## EmuDeck is installed, start setting up stuff
##
#

#Test if we have a successful clone	
if [ -d "$EMUDECKGIT" ]; then
	echo -e "Files Downloaded!"
clear
#cat $EMUDECKGIT/logo.ans
version=$(cat "$EMUDECKGIT/version.md")
echo -e "${BOLD}EmuDeck ${version}${NONE}"
echo -e ""
cat "$EMUDECKGIT/latest.md"

else
	echo -e ""
	echo -e "Backend Files are missing!"
	echo -e "Please close this window and try again in a few minutes"
	sleep 999999
	exit
fi
#
##
## Source all functions and previous values if they exist.
## We source the settings.sh from the emudeck folder if it exists, inside here too.
##
#

source "$EMUDECKGIT/functions/all.sh"

#
#Environment Check
#

getEnvironmentDetails
testRealDeck


if [ "$zenity" == true ]; then

	#This part of the code is where all the settings are created
	
	
	
	#
	## Splash screen
	#
	
	latest=$(cat "$EMUDECKGIT/latest.md")	
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
	# Initialize locations
	#
	locationTable=()
	locationTable+=(TRUE "Internal" "$HOME") #always valid
	
	#built in SD Card reader
	sdCardFull=$(getSDPath)
	sdValid=$(testLocationValid "SD" "$sdCardFull")
	echo "$sdCardFull $sdValid"
    if [[ ! $sdValid =~ "Invalid" ]]; then
		locationTable+=(FALSE "SD Card" "$sdCardFull") 
	fi

	#
	# Installation mode selection
	#
	
	text="$(printf "<b>Hi!</b>\nDo you want to run EmuDeck on Easy or Expert mode?\n\n<b>Easy Mode</b> takes care of everything for you, it is an unattended installation.\n\n<b>Expert mode</b> gives you a bit more of control on how EmuDeck configures your system like giving you the option to install PowerTools or keep your custom configurations per Emulator")"
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
		destination=$(customLocation)
		customValid=$(testLocationValid "Custom" "${destination}")
		echo "$customValid"
		if [[ $customValid =~ "Invalid" ]]; then
			echo "User chose invalid location. Exiting."
			#zenity pop up explaining why
			exit
		fi
	fi
	
	#New paths based on where the user picked.
	setSetting emulationPath "${destination}/Emulation"
	setSetting romsPath "${destination}/Emulation/roms"
	setSetting toolsPath "${destination}/Emulation/tools"
	setSetting biosPath "${destination}/Emulation/bios"
	setSetting savesPath "${destination}/Emulation/saves"
	setSetting storagePath "${destination}/Emulation/storage"
	setSetting ESDEscrapData "${destination}/Emulation/tools/downloaded_media/"

	#Folder creation... This code is repeated outside of this if for the no zenity mode
	mkdir -p "$emulationPath"
	mkdir -p "$toolsPath"/launchers 
	mkdir -p "$savesPath"
	mkdir -p "$romsPath"
	mkdir -p "$storagePath"
	mkdir -p "$biosPath"/yuzu
	
	##Generate rom folders
	setMSG "Creating roms folder in $destination"
	
	sleep 3
	rsync -r --ignore-existing "$EMUDECKGIT/roms/" "$romsPath"/ 
	#End repeated code	
	
	#
	# Start of Expert mode configuration
	# The idea is that Easy mode is unatended, so everything that's out
	# out of the ordinary has to had its flag enabled/disabled on Expert mode
	#	
	
	if [ "$expert" == "true" ]; then
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
	
			expertModeFeatureList=$(zenity  --list --checklist --width=1000 --height="${height}" \
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
				hasPass=$(passwd -S "$USER" | awk -F " " '{print $2}')
				if [[ ! $hasPass == "P" ]]; then
					text="$(printf "<b>Password not set.</b>\n Please set one now in the terminal.\nYou will not see text entry in the terminal for your password. This is normal.\nOnce set, you will be prompted to enter it in a new window.")"
					zenity --error \
					--title="EmuDeck" \
					--width=400 \
					--text="${text}" 2>/dev/null
					sleep 1
					clear
					echo "Enter a new password for the local Deck account here. You will have to enter it twice. No visual indication of typing will occur."
					echo "Please remember it."
					passwd
					ans=$?
					if [[ $ans == 1 ]]; then
						echo "Setting password failed."
					fi
				fi
				PASSWD="$(zenity --password --title="Password Entry" --text="Enter Deck User Password (not Steam account!)" 2>/dev/null)"
				echo "$PASSWD" | sudo -v -S
				ans=$?
				if [[ $ans == 1 ]]; then
					#incorrect password
					PASSWD="$(zenity --password --title="Password Entry" --text="Password was incorrect. Try again. (Did you remember to set a password for linux before running this?)" 2>/dev/null)"
					echo "$PASSWD" | sudo -v -S
					ans=$?
					if [[ $ans == 1 ]]; then
							text="$(printf "<b>Password not accepted.</b>\n Expert mode tools which require a password will not work. Disabling them.")"
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
			emuTable+=(TRUE "PS2" "PCSX2-QT")
			emuTable+=(TRUE "PS3" "RPCS3")
			emuTable+=(TRUE "3DS" "Citra")
			emuTable+=(TRUE "GC/Wii" "Dolphin")
			emuTable+=(TRUE "PSX" "Duckstation")
			emuTable+=(TRUE "PSP" "PPSSPP")
			emuTable+=(TRUE "Switch" "Yuzu")
			emuTable+=(TRUE "WiiU" "Cemu")
			emuTable+=(TRUE "XBox" "Xemu")
			#if we are in beta / dev install, allow Xenia. Still false by default though. Will only work on expert mode, and explicitly turned on.
			if [[ $branch == "beta" || $branch == "dev" ]]; then
				emuTable+=(FALSE "Xbox360" "Xenia")
			fi
			
			#Emulator selector
			text="$(printf "What emulators do you want to install?")"
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
				if [[ "$emusToInstall" == *"PCSX2-QT"* ]]; then
					setSetting doInstallPCSX2QT true
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
			emuTable+=(TRUE "PCSX2-QT")
			emuTable+=(TRUE "RA-BeetlePSX")
			emuTable+=(TRUE "RA-Flycast")
			emuTable+=(TRUE "Xemu")
	
			text="$(printf "Selected Emulators will use WideScreen Hacks")"
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
				if [[ "$wideToInstall" == *"PCSX2-QT"* ]]; then	
					setSetting PCSX2QTWide true
				else
					setSetting PCSX2QTWide false
				fi
			else		
				exit		
			fi			
		fi
		
		if [[ $doResetEmulators == "true" ]]; then
			# Configuration that only appplies to previous users
			if [ -f "$SECONDTIME" ]; then
	
				emuTable=()
				emuTable+=(TRUE "RetroArch")
				emuTable+=(TRUE "PrimeHack")
				emuTable+=(TRUE "PCSX2")
				emuTable+=(TRUE "PCSX2-QT")
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
	
				text="$(printf "<b>EmuDeck will reset the following Emulator's configurations by default.</b>\nWhich systems do you want <b>reset</b> to the newest version of the defaults?\nWe recommend you keep all of them checked so everything gets updated and known issues are fixed.\nIf you want to mantain any custom configuration on an emulator unselect its name from this list.")"
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
				cat "$EMUDECKGIT/logo.ans"
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
					if [[ "$emusToReset" == *"PCSX2"* ]]; then
						setSetting doSetupPCSX2QT true
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
		setSetting doInstallPCSX2QT true
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
		setSetting pcsx2QTWide false	
	
	fi # end Expert if


else
	#We only load functions and config when no Zenity selected
	#source "$EMUDECKGIT"/functions/all.sh - if we ALWAYS source, 
	#then we can do stuff like having the settings exactly the way they were on second run.
	#source $HOME/emudeck/settings.sh put it inside all.sh
	
	#Folder creation... This code is repeated outside of this if for the yes zenity mode
	mkdir -p "$emulationPath"
	mkdir -p "$toolsPath"/launchers 
	mkdir -p "$savesPath"
	mkdir -p "$romsPath"
	mkdir -p "$storagePath"
	mkdir -p "$biosPath"/yuzu
	
	##Generate rom folders
	setMSG "Creating roms folder in $romsPath"
	
	sleep 3
	rsync -r --ignore-existing "$EMUDECKGIT/roms/" "$romsPath" 
	#End repeated code	
fi


#
##
## End of Zenity configuration
##	
#


	
	
#
##
## Start of installation
##	
#

#Support for non-holo based OS's
#Only on Zenity for now
if [ "$zenity" == true ]; then
	if [[ $isRealDeck == false ]]; then
		OS_setupPrereqsArch
	fi
fi
#setup Proton-Launch.sh
#because this path gets updated by sed, we really should be installing it every time and allowing it to be updated every time. In case the user changes their path.
cp "$EMUDECKGIT/tools/proton-launch.sh" "${toolsPath}/proton-launch.sh"
chmod +x "${toolsPath}/proton-launch.sh"

#ESDE Installation
if [ $doInstallESDE == "true" ]; then
	ESDE_install		
fi
#SRM Installation
if [ $doInstallSRM == "true" ]; then
	SRM_install
fi
#Emulators Installation
if [ "$doInstallPCSX2" == "true" ]; then	
	PCSX2_install
fi
if [ "$doInstallPCSX2QT" == "true" ]; then	
	PCSX2QT_install
fi
if [ $doInstallPrimeHacks == "true" ]; then
	Primehack_install
fi
if [ $doInstallRPCS3 == "true" ]; then
	RPCS3_install
fi
if [ $doInstallCitra == "true" ]; then
	Citra_install
fi
if [ $doInstallDolphin == "true" ]; then
	Dolphin_install
fi
if [ $doInstallDuck == "true" ]; then
	DuckStation_install
fi
if [ $doInstallRA == "true" ]; then
	RetroArch_install	
fi
if [ $doInstallPPSSPP == "true" ]; then
	PPSSPP_install	
fi
if [ $doInstallYuzu == "true" ]; then	
	Yuzu_install
fi
if [ $doInstallXemu == "true" ]; then
	Xemu_install
fi
if [ $doInstallCemu == "true" ]; then
	Cemu_install
fi

#Xenia - We need to install Xenia after creating the Roms folders!
if [ "$doInstallXenia" == "true" ]; then
	Xenia_install
fi

#Steam RomManager Config

if [ "$doSetupSRM" == "true" ]; then
	SRM_init
fi

#ESDE Config
if [ "$doSetupESDE" == "true" ]; then
	ESDE_init
fi	

#Emus config
#setMSG "Configuring Steam Input for emulators.." moved to emu install


setMSG "Configuring emulators.."

if [ "$doSetupRA" == "true" ]; then
	RetroArch_init
fi
if [ "$doSetupPrimeHacks" == "true" ]; then
	Primehack_init
fi
if [ "$doSetupDolphin" == "true" ]; then
	Dolphin_init
fi
if [ "$doSetupPCSX2" == "true" ]; then
	PCSX2_init
fi
if [ "$doSetupPCSX2QT" == "true" ]; then
	PCSX2QT_init
fi
if [ "$doSetupRPCS3" == "true" ]; then
	RPCS3_init
fi
if [ "$doSetupCitra" == "true" ]; then
	Citra_init
fi
if [ "$doSetupDuck" == "true" ]; then
	DuckStation_init
fi
if [ "$doSetupYuzu" == "true" ]; then
	Yuzu_init
fi
if [ "$doSetupPPSSPP" == "true" ]; then
	PPSSPP_init
fi
if [ "$doSetupXemu" == "true" ]; then
	Xemu_init
fi
#Proton Emus
if [ "$doSetupCemu" == "true" ]; then
	Cemu_init
fi
if [ "$doSetupXenia" == "true" ]; then
	Xenia_init
fi



#Fixes repeated Symlink for older installations
Yuzu_finalize



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



#RA AutoSave	
if [ "$RAautoSave" == true ]; then
	RetroArch_autoSaveOn
else
	RetroArch_autoSaveOff
fi	



if [ "$zenity" == true ]; then
	
	#Old Widescreen hacks
	if [ "$duckWide" == true ]; then	
		DuckStation_wideScreenOn
	else
		DuckStation_wideScreenOff
	fi
	if [ "$pcsx2QTWide" == true ]; then	
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


if [ "$doInstallCHD" == "true" ]; then
	CHD_install
fi

if [ "$doInstallGyro" == "true" ]; then	
	Plugins_installSteamDeckGyroDSU
fi


if [ "$doInstallPowertools" == "true" ]; then
	Plugins_installPluginLoader
	Plugins_installPowerTools
fi

if [ "$branch" == 'main' ];then
	createDesktopIcons
fi

BINUP_install


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
	if [ "$zenity" == true ]; then
	text="$(printf "<b>Yuzu is not configured</b>\nYou need to copy your Keys and firmware to: \n${biosPath}yuzu/keys\n${biosPath}yuzu/firmware\n\nMake sure to copy your files inside the folders. <b>Do not overwrite them</b>")"
	zenity --error \
			--title="EmuDeck" \
			--width=400 \
			--text="${text}" 2>/dev/null
	else
		echo "$text"
	fi
fi

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


#
# We mark the script as finished	
#
echo "" > "$HOME/emudeck/.finished"
echo "" > "$HOME/emudeck/.electron-finished"
echo "100" > "$HOME/emudeck/msg.log"
echo "# Installation Complete" >> "$HOME/emudeck/msg.log"
finished=true
rm "$PIDFILE"

if [ "$zenity" == true ]; then

	text="$(printf "<b>Done!</b>\n\nRemember to add your games here:\n<b>${romsPath}</b>\nAnd your Bios (PS1, PS2, Yuzu) here:\n<b>${biosPath}</b>\n\nOpen Steam Rom Manager on your Desktop to add your games to your SteamUI Interface.\n\nThere is a bug in RetroArch that if you are using Bezels you can not set save configuration files unless you close your current game. Use overrides for your custom configurations or use expert mode to disabled them\n\nIf you encounter any problem please visit our Discord:\n<b>https://discord.gg/b9F7GpXtFP</b>\n\nTo Update EmuDeck in the future, just run this App again.\n\nEnjoy!")"
	
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

fi