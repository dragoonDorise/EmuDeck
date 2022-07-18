#!/bin/bash

#
##
## Downloading files...
##
#

# Which branch?
devMode=$1
case $devMode in
  "BETA")
	branch="beta"
  ;;
  "DEV")
	  branch="dev"
	;;  
  *)
	branch="main"
  ;;
esac

#Clean up previous installations
rm ~/emudek.log 2>/dev/null # This is emudeck's old log file, it's not a typo!
rm -rf ~/dragoonDoriseTools
mkdir -p ~/emudeck

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

# Seeting up the progress Bar for the rest of the installation
finished=false
echo "0" > ~/emudeck/msg.log
echo "# Downloading files from $branch channel..." >> ~/emudeck/msg.log
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
  --text="Downloading files from $branch channel..." \
  --percentage=0 \
  --no-cancel \
  --pulsate \
  --auto-close \
  --width=300 \ &

if [ "$?" = -1 ] ; then
	zenity --error \
	--text="Update canceled."
fi

#We create all the needed folders for installation
mkdir -p ~/dragoonDoriseTools/EmuDeck
cd ~/dragoonDoriseTools

#Cloning EmuDeck files
git clone https://github.com/dragoonDorise/EmuDeck.git ~/dragoonDoriseTools/EmuDeck 
if [ ! -z "$devMode" ]; then
	cd ~/dragoonDoriseTools/EmuDeck
	git checkout $branch 
fi


#Test if we have a successful clone
EMUDECKGIT=~/dragoonDoriseTools/EmuDeck
if [ -d "$EMUDECKGIT" ]; then
	echo -e "Files Downloaded!"
clear
cat ~/dragoonDoriseTools/EmuDeck/logo.ans
version=$(cat ~/dragoonDoriseTools/EmuDeck/version.md)
echo -e "${BOLD}EmuDeck ${version}${NONE}"
echo -e ""
cat ~/dragoonDoriseTools/EmuDeck/latest.md

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


#
## Settings
#
#Check for config file
FILE=~/emudeck/settings.sh
if [ -f "$FILE" ]; then
	source $FILE
	else
	cp "$EMUDECKGIT"/settings.sh ~/emudeck/settings.sh	
fi

#
## Functions
#

source "$EMUDECKGIT"/functions/all.sh

#
## extra Binaries to path
#
export PATH="${EMUDECKGIT}/tools/binaries/:$PATH"
chmod +x "${EMUDECKGIT}/tools/binaries/xmlstarlet"

#
## Splash screen
#

latest=$(cat ~/dragoonDoriseTools/EmuDeck/latest.md)	
if [ -f "$SECONDTIME" ]; then
	 text="$(printf "<b>Hi, this is the changelog of the new features added in this version</b>\n\n${latest}")"
	 width=1000
else
	text="$(printf "<b>Welcome to EmuDeck!</b>")"
	width=300
fi 
 zenity --info \
--title="EmuDeck" \
--width=${width} \
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
ESDEscrapData="${destination}/Emulation/tools/downloaded_media"

#Folder creation...
mkdir -p "$emulationPath"
mkdir -p "$toolsPath"launchers 
mkdir -p "$savesPath"
mkdir -p "$romsPath"
mkdir -p "$storagePath"
mkdir -p "$biosPath"yuzu

##Generate rom folders
setMSG "Creating roms folder in $destination"

sleep 3
rsync -r --ignore-existing ~/dragoonDoriseTools/EmuDeck/roms/ "$romsPath" 

#
# Start of Expert mode configuration
# The idea is that Easy mode is unatended, so everything that's out
# out of the ordinary has to had its flag enabled/disabled on Expert mode
#	

if [ $expert == "true" ]; then
	echo "Expert mode begin"
		#set all features to false
		doInstallCHD=false
		doInstallPowertools=false
		doInstallGyro=false
		doSetupSRM=false
		doInstallESDE=false
		doSelectEmulators=false
		doResetEmulators=false
		doSelectRABezels=false
		doSelectRAAutoSave=false
		doSNESAR87=false
		doSelectWideScreen=false
		doRASignIn=false
		doRAEnable=false
		doESDEThemePicker=false
		doXboxButtons=false		
	
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
			doInstallCHD=true
		fi
		if [[ "$expertModeFeatureList" == *"PowerTools"* ]]; then
			doInstallPowertools=true
		fi
		if [[ "$expertModeFeatureList" == *"SteamGyro"* ]]; then
			doInstallGyro=true
		fi
		if [[ "$expertModeFeatureList" == *"updateSRM"* ]]; then
			doSetupSRM=true
		else
			doSetupSRM=false
		fi
		if [[ "$expertModeFeatureList" == *"updateESDE"* ]]; then
			doInstallESDE=true
		else
			doInstallESDE=false
		fi
		if [[ "$expertModeFeatureList" == *"selectEmulators"* ]]; then
			doSelectEmulators=true
		fi
		if [[ "$expertModeFeatureList" == *"selectEmulatorConfig"* ]]; then
			doResetEmulators=true
		fi
		if [[ "$expertModeFeatureList" == *"selectRABezels"* ]]; then
			RABezels=true
		else
			RABezels=false
		fi
		if [[ "$expertModeFeatureList" == *"selectRAAutoSave"* ]]; then
			RAautoSave=true
		else
			RAautoSave=false
		fi
		if [[ "$expertModeFeatureList" == *"snesAR"* ]]; then
			SNESAR=43
		else
			SNESAR=87		
		fi
		if [[ "$expertModeFeatureList" == *"selectWideScreen"* ]]; then
			doSelectWideScreen=true			
		fi
		if [[ "$expertModeFeatureList" == *"setRASignIn"* ]]; then
			doRASignIn=true
		fi
		if [[ "$expertModeFeatureList" == *"setRAEnable"* ]]; then
			doRAEnable=true
		fi
		if [[ "$expertModeFeatureList" == *"doESDEThemePicker"* ]]; then
			doESDEThemePicker=true
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
						doInstallPowertools=false
						doInstallGyro=false
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
			echo "User selected: $emusToInstall"
			if [[ "$emusToInstall" == *"RetroArch"* ]]; then
				doInstallRA=true
			fi
			if [[ "$emusToInstall" == *"PrimeHack"* ]]; then
				doInstallPrimeHacks=true
			fi
			if [[ "$emusToInstall" == *"PCSX2"* ]]; then
				doInstallPCSX2=true
			fi
			if [[ "$emusToInstall" == *"RPCS3"* ]]; then
				doInstallRPCS3=true
			fi
			if [[ "$emusToInstall" == *"Citra"* ]]; then
				doInstallCitra=true
			fi
			if [[ "$emusToInstall" == *"Dolphin"* ]]; then
				doInstallDolphin=true
			fi
			if [[ "$emusToInstall" == *"Duckstation"* ]]; then
				doInstallDuck=true
			fi
			if [[ "$emusToInstall" == *"PPSSPP"* ]]; then
				doInstallPPSSPP=true
			fi
			if [[ "$emusToInstall" == *"Yuzu"* ]]; then
				doInstallYuzu=true
			fi
			if [[ "$emusToInstall" == *"Cemu"* ]]; then
				doInstallCemu=true
			fi
			if [[ "$emusToInstall" == *"Xemu"* ]]; then
				doInstallXemu=true
			fi
			if [[ "$emusToInstall" == *"Xenia"* ]]; then
				doInstallXenia=true
			fi
			#if [[ "$emusToInstall" == *"MelonDS"* ]]; then
			#	doInstallMelon=true
			#fi
		
		
		else
			exit
		fi
	fi
	#We force new Cemu install if we detect an older version exists
	DIR=$romsPath/wiiu/roms/
	if [ -d "$DIR" ]; then	#this is always true i think.
		doInstallCemu=true	
	fi	
	

	if [[ $doSelectWideScreen == "true" ]]; then
		#Emulators screenHacks
		emuTable=()
		emuTable+=(TRUE "Dolphin")
		emuTable+=(TRUE "Duckstation")
		emuTable+=(TRUE "BeetlePSX")
		emuTable+=(TRUE "Dreamcast")

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
			echo "User selected: $wideToInstall"
			if [[ "$wideToInstall" == *"Duckstation"* ]]; then
				duckWide=true
			else
				duckWide=false
			fi
			if [[ "$wideToInstall" == *"Dolphin"* ]]; then
				DolphinWide=true
			else
				DolphinWide=false
			fi
			if [[ "$wideToInstall" == *"Dreamcast"* ]]; then
				DreamcastWide=true
			else
				DreamcastWide=false
			fi		
			if [[ "$wideToInstall" == *"BeetlePSX"* ]]; then
				BeetleWide=true
				else
				BeetleWide=false
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
			#We make sure all the emus can write its saves outside its own folders.
			#Also needed for certain emus to open certain menus for adding rom directories in the front end.
			#flatpak override net.pcsx2.PCSX2 --filesystem=host --user
			flatpak override net.pcsx2.PCSX2 --share=network --user # for network access / online play
			flatpak override io.github.shiiion.primehack --filesystem=host --user
			flatpak override net.rpcs3.RPCS3 --filesystem=host --user
			flatpak override org.citra_emu.citra --filesystem=host --user
			flatpak override org.DolphinEmu.dolphin-emu --filesystem=host --user
			#flatpak override org.duckstation.DuckStation --filesystem=host --user
			#flatpak override org.libretro.RetroArch --filesystem=host --user
			#flatpak override org.ppsspp.PPSSPP --filesystem=host --user
			flatpak override org.yuzu_emu.yuzu --filesystem=host --user
			flatpak override app.xemu.xemu --filesystem=/run/media:rw --user
			flatpak override app.xemu.xemu --filesystem="$savesPath"xemu:rw --user

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
			cat ~/dragoonDoriseTools/EmuDeck/logo.ans
			echo -e "EmuDeck ${version}"
			if [ $ans -eq 0 ]; then
				echo "User selected: $emusToReset"
				if [[ "$emusToReset" == *"RetroArch"* ]]; then
					doSetupRA=true
				fi
				if [[ "$emusToReset" == *"PrimeHack"* ]]; then
					doSetupPrimeHacks=true
				fi
				if [[ "$emusToReset" == *"PCSX2"* ]]; then
					doSetupPCSX2=true
				fi
				if [[ "$emusToReset" == *"RPCS3"* ]]; then
					doSetupRPCS3=true
				fi
				if [[ "$emusToReset" == *"Citra"* ]]; then
					doSetupCitra=true
				fi
				if [[ "$emusToReset" == *"Dolphin"* ]]; then
					doSetupDolphin=true
				fi
				if [[ "$emusToReset" == *"Duckstation"* ]]; then
					doSetupDuck=true
				fi
				if [[ "$emusToReset" == *"PPSSPP"* ]]; then
					doSetupPPSSPP=true
				fi
				if [[ "$emusToReset" == *"Yuzu"* ]]; then
					doSetupYuzu=true
				fi
				if [[ "$emusToReset" == *"Cemu"* ]]; then
					doSetupCemu=true
				fi
				if [[ "$emusToReset" == *"Xemu"* ]]; then
					doSetupXemu=true
				fi
				if [[ "$emusToReset" == *"Xenia"* ]]; then
					doSetupXenia=false #false until we add above
				fi
				#if [[ "$emusToReset" == *"MelonDS"* ]]; then
				#	doSetupMelon=false
				#fi
				if [[ "$emusToReset" == *"Steam Rom Manager"* ]]; then
					doSetupSRM=true
				fi
				if [[ "$emusToReset" == *"EmulationStation DE"* ]]; then
					doSetupESDE=true
				fi
			
			
			else
				echo ""
			fi
			
		fi
	fi
else
	#easy mode settings
	doInstallRA=true
	doInstallDolphin=true
	doInstallPCSX2=true
	doInstallRPCS3=true
	doInstallYuzu=true
	doInstallCitra=true
	doInstallDuck=true
	doInstallCemu=true
	doInstallXenia=false
	doInstallPrimeHacks=true
	doInstallPPSSPP=true
	doInstallXemu=true
	#doInstallMelon=true

	#widescreen off by default
	duckWide=false
	DolphinWide=false
	DreamcastWide=false
	BeetleWide=false

fi # end Expert if

##
##
## End of configuration
##	
##
	
	
	
	
##
##
## Start of installation
##	
##
## First up - migrate things that need to move.
echo "begin migrations"
doMigrations

#ESDE Installation
if [ $doInstallESDE == "true" ]; then
	installESDE		
fi
	
#SRM Installation
if [ $doInstallSRM == "true" ]; then
	installSRM
fi

#Support for non-valve hardware.
#if [[ $isRealDeck == false ]]; then
#	 setUpHolo
#fi

#Emulators Installation
if [ $doInstallPCSX2 == "true" ]; then	
	installEmuFP "PCSX2" "net.pcsx2.PCSX2"		
fi
if [ $doInstallPrimeHacks == "true" ]; then
	installEmuFP "PrimeHack" "io.github.shiiion.primehack"		
fi
if [ $doInstallRPCS3 == "true" ]; then
	installEmuFP "RPCS3" "net.rpcs3.RPCS3"		
fi
if [ $doInstallCitra == "true" ]; then
	installEmuFP "Citra" "org.citra_emu.citra"		
fi
if [ $doInstallDolphin == "true" ]; then
	installEmuFP "dolphin-emu" "org.DolphinEmu.dolphin-emu"
fi
if [ $doInstallDuck == "true" ]; then
	installEmuFP "DuckStation" "org.duckstation.DuckStation"		
fi
if [ $doInstallRA == "true" ]; then
	installEmuFP "RetroArch" "org.libretro.RetroArch"		
fi
if [ $doInstallPPSSPP == "true" ]; then
	installEmuFP "PPSSPP" "org.ppsspp.PPSSPP"		
fi
if [ $doInstallYuzu == "true" ]; then
	#installEmuFP "Yuzu" "org.yuzu_emu.yuzu"	
	installEmuAI "yuzu"  $(getLatestReleaseURLGH "yuzu-emu/yuzu-mainline" "AppImage") #needs to be lowercase yuzu for EsDE to find it.
fi
if [ $doInstallXemu == "true" ]; then
	installEmuFP "Xemu-Emu" "app.xemu.xemu"	
fi




#Cemu - We need to install Cemu after creating the Roms folders!
if [ $doInstallCemu == "true" ]; then
	setMSG "Installing Cemu"		
	FILE="${romsPath}/wiiu/Cemu.exe"	
	if [ -f "$FILE" ]; then
		echo "Cemu.exe already exists"
	else
		curl https://cemu.info/releases/cemu_1.26.2.zip --output "$romsPath"wiiu/cemu_1.26.2.zip 
		mkdir -p "$romsPath"wiiu/tmp
		unzip -o "$romsPath"wiiu/cemu_1.26.2.zip -d "$romsPath"wiiu/tmp 
		mv "$romsPath"wiiu/tmp/*/* "$romsPath"/wiiu 
		rm -rf "$romsPath"wiiu/tmp 
		rm -f "$romsPath"wiiu/cemu_1.26.2.zip 		
	fi

	#because this path gets updated by sed, we really should be installing it every time and allowing it to be updated every time. In case the user changes their path.
	cp ~/dragoonDoriseTools/EmuDeck/tools/proton-launch.sh "${toolsPath}"proton-launch.sh
	chmod +x "${toolsPath}"proton-launch.sh
	cp ~/dragoonDoriseTools/EmuDeck/tools/launchers/cemu.sh "${toolsPath}"launchers/cemu.sh
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|" "${toolsPath}"launchers/cemu.sh
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/wiiu|${romsPath}wiiu|" "${toolsPath}"launchers/cemu.sh
	chmod +x "${toolsPath}"launchers/cemu.sh

	
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
	configSRM
fi

#ESDE Config
if [ $doSetupESDE == "true" ]; then
	configESDE
fi	

#Emus config
setMSG "Configuring Steam Input for emulators.."
rsync -r ~/dragoonDoriseTools/EmuDeck/configs/steam-input/ ~/.steam/steam/controller_base/templates/

setMSG "Configuring emulators.."
echo -e ""
if [ $doSetupRA == "true" ]; then

	mkdir -p ~/.var/app/org.libretro.RetroArch
	mkdir -p ~/.var/app/org.libretro.RetroArch/config
	mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch
	
	RACores
	
	raConfigFile=~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg
	FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
	if [ -f "$FILE" ]; then
		echo -e "" 2>/dev/null
	else
		setMSG "Backing up RA..."
		cp ~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak 	
	fi
	#mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch/overlays
	
	#Cleaning up cfg files that the user could have created on Expert mode
	find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" | while read f; do rm -f "$f"; done 
	find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.bak" | while read f; do rm -f "$f"; done 
	
	rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/ ~/.var/app/org.libretro.RetroArch/config/
	
	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" $raConfigFile	
	
fi
echo -e ""
setMSG "Applying Emu configurations..."
if [ $doSetupPrimeHacks == "true" ]; then
	configEmuFP "PrimeHack" "io.github.shiiion.primehack"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.var/app/io.github.shiiion.primehack/config/dolphin-emu/Dolphin.ini
fi
if [ $doSetupDolphin == "true" ]; then
	configEmuFP "Dolphin" "org.DolphinEmu.dolphin-emu"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini
fi
if [ $doSetupPCSX2 == "true" ]; then
	configEmuFP "PCSX2" "net.pcsx2.PCSX2"
	#Bios Fix
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios|${biosPath}|g" ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini 
fi
if [ $doSetupRPCS3 == "true" ]; then
	configEmuFP "RPCS3" "net.rpcs3.RPCS3"
	#HDD Config
	sed -i 's| $(EmulatorDir)dev_hdd0/| '$storagePath'/rpcs3/dev_hdd0/|g' $HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml 
	mkdir -p $storagePath/rpcs3/ 
fi
if [ $doSetupCitra == "true" ]; then
	configEmuFP "Citra" "org.citra_emu.citra"
	#Roms Path
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" $HOME/.var/app/org.citra_emu.citra/config/citra-emu/qt-config.ini
fi
if [ $doSetupDuck == "true" ]; then
	configEmuFP "DuckStation" "org.duckstation.DuckStation"
	#Bios Path
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios/|${biosPath}|g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini
fi
if [ $doSetupYuzu == "true" ]; then
	configEmuAI "yuzu" "config" "$HOME/.config/yuzu" "$HOME/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/config/yuzu" "true"
	configEmuAI "yuzu" "data" "$HOME/.local/share/yuzu" "$HOME/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/data/yuzu" "true"
	#Roms Path
	sed -i "s|/run/media/mmcblk0p1/|${destination}/|g" "$HOME/.config/yuzu/qt-config.ini"
	mkdir -p ${storagePath}yuzu/dump
	mkdir -p ${storagePath}yuzu/load
	mkdir -p ${storagePath}yuzu/sdmc
	mkdir -p ${storagePath}yuzu/nand
	mkdir -p ${storagePath}yuzu/screenshots
	mkdir -p ${storagePath}yuzu/tas
fi

if [ $doSetupPPSSPP == "true" ]; then
	configEmuFP "PPSSPP" "org.ppsspp.PPSSPP"
fi
if [ $doSetupXemu == "true" ]; then
	configEmuFP "Xemu" "app.xemu.xemu"	
	#Bios Fix
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios/|${biosPath}|g" ~/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.ini
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios/|${biosPath}|g" ~/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml
	sed -i "s|/run/media/mmcblk0p1/Emulation/saves/|${storagePath}|g" ~/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml
	if [[ ! -f "${storagePath}xemu/xbox_hdd.qcow2" ]]; then
		mkdir -p "${storagePath}xemu"
		cd "${storagePath}xemu"
		curl -Lo "xbox_hdd.qcow2.zip" "https://github.com/mborgerson/xemu-hdd-image/releases/latest/download/xbox_hdd.qcow2.zip" && unzip -j xbox_hdd.qcow2.zip && rm -rf xbox_hdd.qcow2.zip
	fi
fi

#Proton Emus
if [ $doSetupCemu == "true" ]; then
	echo "" 
	#Commented until we get CEMU flatpak working
	#rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/info.cemu.Cemu/ ~/.var/app/info.cemu.Cemu/ 
	cemuSettings="${romsPath}wiiu/settings.xml"
	mv -f $cemuSettings $cemuSettings.bak #retain cemusettings if it exists to stop wiping peoples mods. Just insert our search path for installed games.
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/info.cemu.Cemu/data/cemu/ "${romsPath}wiiu"
	rm $cemuSettings
	mv -f $cemuSettings.bak $cemuSettings
	if [[ -f "${cemuSettings}" ]]; then
		gamePathEntryFound=$(grep -rnw $cemuSettings -e "z:${romsPath}wiiu/roms")
		if [[ $gamePathEntryFound == '' ]]; then 
			xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "z:${romsPath}wiiu/roms" $cemuSettings
		fi
	fi
fi
if [ $doSetupXenia == "true" ]; then
	echo "" 
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/xenia/ "$romsPath"/xbox360 
fi



#Setup Bios symlinks
unlink ${biosPath}yuzu/keys
mkdir -p "$HOME/.local/share/yuzu/keys/"
ln -sn "$HOME/.local/share/yuzu/keys/" ${biosPath}yuzu/keys

unlink ${biosPath}yuzu/firmware
mkdir -p ${storagePath}yuzu/nand/system/Contents/registered/
touch ${storagePath}yuzu/nand/system/Contents/registered/putfirmwarehere.txt
ln -sn ${storagePath}yuzu/nand/system/Contents/registered/ ${biosPath}yuzu/firmware

#Fixes repeated Symlink for older installations
cd ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/
unlink keys 
cd ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered/
unlink registered 



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

#We move all the saved folders to the emulation path
createSaveFolders

#RetroAchievments
RAAchievment


if [ $doInstallCHD == "true" ]; then
	installCHD
fi

if [ $doInstallGyro == "true" ]; then	
		InstallGyro=$(bash <(curl -sL https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh))
		echo $InstallGyro 
fi


if [ $doInstallPowertools == "true" ]; then
	installPowerTools	
fi

if [ $branch == 'main' ];then
	createDesktopIcons
fi

installBinUp

setMSG "Cleaning up downloaded files..."	
rm -rf ~/dragoonDoriseTools	
clear

# We mark the script as finished	
echo "" > ~/emudeck/.finished
echo "100" > ~/emudeck/msg.log
echo "# Installation Complete" >> ~/emudeck/msg.log
finished=true

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
