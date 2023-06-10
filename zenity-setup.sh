#!/bin/bash

# Seeting up the progress Bar for the rest of the installation
finished=false
MSG=$HOME/.config/EmuDeck/msg.log
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

#createFolders I think we dont need this anymore in here

#
# Start of Expert mode configuration
# The idea is that Easy mode is unatended, so everything that's out
# out of the ordinary has to had its flag enabled/disabled on Expert mode
#	

if [ "$expert" == "true" ]; then
	echo "Expert mode begin"
	
		#one entry per expert mode feature
		table=()
		#table+=(TRUE "CHDScript" "Install the latest version of our CHD conversion script?")
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

		if [[ ! $branch == "main" ]]; then 
			table+=(TRUE "SaveSync" "Setup Save Synchronization for Emudeck to a cloud provider")
		fi

		declare -i height=(${#table[@]}*40)

		expertModeFeatureList=$(zenity  --list --checklist --width=1000 --height="${height}" \
		--column="Select?"  \
		--column="Features"  \
		--column="Description" \
		--hide-column=2 \
		"${table[@]}" 2>/dev/null)
		echo "user selected: $expertModeFeatureList"
		#set flags to true for selected expert mode features
		#if [[ "$expertModeFeatureList" == *"CHDScript"* ]]; then
		#	setSetting doInstallCHD true
		#fi
		if [[ "$expertModeFeatureList" == *"PowerTools"* ]]; then
			setSetting doInstallPowertools true
		else
			setSetting doInstallPowertools false
		fi
		if [[ "$expertModeFeatureList" == *"SteamGyro"* ]]; then
			setSetting doInstallGyro true
		else
			setSetting doInstallGyro false
		fi
		if [[ "$expertModeFeatureList" == *"SaveSync"* ]]; then
			setSetting doSetupSaveSync true
		else
			setSetting doSetupSaveSync false
		fi
		if [[ "$expertModeFeatureList" == *"updateSRM"* ]]; then
			setSetting doSetupSRM true
		else
			setSetting doSetupSRM false
		fi
		if [[ "$expertModeFeatureList" == *"updateESDE"* ]]; then
			setSetting doInstallESDE true
		else
			setSetting doInstallESDE false
		fi
		if [[ "$expertModeFeatureList" == *"selectEmulators"* ]]; then
			setSetting doSelectEmulators true
		else
			setSetting doSelectEmulators false
		fi
		if [[ "$expertModeFeatureList" == *"selectEmulatorConfig"* ]]; then
			setSetting doResetEmulators true
		else
			setSetting doResetEmulators false
		fi
		if [[ "$expertModeFeatureList" == *"selectRABezels"* ]]; then
			setSetting RABezels true
		else
			setSetting RABezels false
		fi
		if [[ "$expertModeFeatureList" == *"selectRAAutoSave"* ]]; then
			setSetting RAautoSave true
		else
			setSetting RAautoSave false
		fi
		if [[ "$expertModeFeatureList" == *"snesAR"* ]]; then
			setSetting SNESAR 43	
		else
			setSetting SNESAR 87
		fi
		if [[ "$expertModeFeatureList" == *"selectWideScreen"* ]]; then
			setSetting doSelectWideScreen true			
		else
			setSetting doSelectWideScreen false
		fi
		if [[ "$expertModeFeatureList" == *"setRASignIn"* ]]; then
			setSetting doRASignIn true
		else
			setSetting doRASignIn false
		fi
		if [[ "$expertModeFeatureList" == *"setRAEnable"* ]]; then
			setSetting doRAEnable true
		else
			setSetting doRAEnable false
		fi
		if [[ "$expertModeFeatureList" == *"doESDEThemePicker"* ]]; then
			setSetting doESDEThemePicker true
		else
			setSetting doESDEThemePicker false
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
	if [[ $doESDEThemePicker == true ]]; then	
		text="Which theme do you want to set for EmulationStation-DE?"
		esdeTheme=$(zenity --list \
		--title="EmuDeck" \
		--height=250 \
		--width=250 \
		--ok-label="OK" \
		--cancel-label="Exit" \
		--text="${text}" \
		--radiolist \
		--column="" \
		--column="Theme" \
		1 "EPICNOIR" \
		2 "MODERN-DE" \
		3 "RBSIMPLE-DE" 2>/dev/null)
		ans=$?	
		if [ $ans -eq 0 ]; then
			echo "Theme selected: $esdeTheme" 
			setSetting esdeTheme $esdeTheme
		fi
	fi


	if [[ $doSelectEmulators == "true" ]]; then
		
		emuTable=()
		emuTable+=(TRUE "Multiple" "RetroArch")
		emuTable+=(TRUE "Arcade" "MAME")
		emuTable+=(TRUE "Metroid Prime" "PrimeHack")
		emuTable+=(TRUE "PS2" "PCSX2-Legacy")
		emuTable+=(TRUE "PS2" "PCSX2-QT")
		emuTable+=(TRUE "PS3" "RPCS3")
		emuTable+=(TRUE "3DS" "Citra")
		emuTable+=(TRUE "GC/Wii" "Dolphin")
		emuTable+=(TRUE "PSX" "Duckstation")
		emuTable+=(TRUE "PSP" "PPSSPP")
		emuTable+=(TRUE "Switch" "Yuzu")
		emuTable+=(TRUE "Switch" "Ryujinx")
		emuTable+=(TRUE "WiiU" "Cemu")
		emuTable+=(TRUE "XBox" "Xemu")
		emuTable+=(TRUE "N64" "RMG")
		emuTable+=(FALSE "GameBoy / Color / Advance" "mGBA")
		
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
			else
				setSetting doInstallRA false
			fi
			if [[ "$emusToInstall" == *"PrimeHack"* ]]; then
				setSetting doInstallPrimeHack true
			else
				setSetting doInstallPrimeHack false
			fi
			if [[ "$emusToInstall" == *"PCSX2-Legacy"* ]]; then
				setSetting doInstallPCSX2 true
			else
				setSetting doInstallPCSX2 false
			fi
			if [[ "$emusToInstall" == *"PCSX2-QT"* ]]; then
				setSetting doInstallPCSX2QT true
			else
				setSetting doInstallPCSX2QT false
			fi
			if [[ "$emusToInstall" == *"RPCS3"* ]]; then
				setSetting doInstallRPCS3 true
			else
				setSetting doInstallRPCS3 false
			fi
			if [[ "$emusToInstall" == *"Citra"* ]]; then
				setSetting doInstallCitra true
			else
				setSetting doInstallCitra false
			fi
			if [[ "$emusToInstall" == *"Dolphin"* ]]; then
				setSetting doInstallDolphin true
			else
				setSetting doInstallDolphin false
			fi
			if [[ "$emusToInstall" == *"Duckstation"* ]]; then
				setSetting doInstallDuck true
			else
				setSetting doInstallDuck false
			fi
			if [[ "$emusToInstall" == *"PPSSPP"* ]]; then
				setSetting doInstallPPSSPP true
			else
				setSetting doInstallPPSSPP false
			fi
			if [[ "$emusToInstall" == *"mGBA"* ]]; then
				setSetting doInstallMGBA true
			else
				setSetting doInstallMGBA false
			fi
			if [[ "$emusToInstall" == *"Yuzu"* ]]; then
				setSetting doInstallYuzu true
			else
				setSetting doInstallYuzu false
			fi
			if [[ "$emusToInstall" == *"Ryujinx"* ]]; then
				setSetting doInstallRyujinx true
			else
				setSetting doInstallRyujinx false
			fi
			if [[ "$emusToInstall" == *"Cemu"* ]]; then
				setSetting doInstallCemu true
			else
				setSetting doInstallCemu false
			fi
			if [[ "$emusToInstall" == *"Xemu"* ]]; then
				setSetting doInstallXemu true
			else
				setSetting doInstallXemu false
			fi
			if [[ "$emusToInstall" == *"Xenia"* ]]; then
				setSetting doInstallXenia true
			else
				setSetting doInstallXenia false
			fi
			#if [[ "$emusToInstall" == *"MelonDS"* ]]; then
			#	doInstallMelon=true
			#fi
			if [[ "$emusToInstall" == *"RMG"* ]]; then
				setSetting doInstallRMG true
			else
				setSetting doInstallRMG false
			fi		
		
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
			emuTable+=(TRUE "MAME")
			emuTable+=(TRUE "PrimeHack")
			emuTable+=(TRUE "PCSX2-Legacy")
			emuTable+=(TRUE "PCSX2-QT")
			emuTable+=(TRUE "RPCS3")
			emuTable+=(TRUE "Citra")
			emuTable+=(TRUE "Dolphin")
			emuTable+=(TRUE "Duckstation")
			emuTable+=(TRUE "PPSSPP")
			emuTable+=(TRUE "Yuzu")
			emuTable+=(TRUE "Ryujinx")
			emuTable+=(TRUE "Cemu")
			emuTable+=(TRUE "Xemu")
			emuTable+=(TRUE "Steam Rom Manager")
			emuTable+=(TRUE "EmulationStation DE")
			emuTable+=(TRUE "RMG")


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
				else
					setSetting doSetupRA false
				fi
				if [[ "$emusToReset" == *"PrimeHack"* ]]; then
					setSetting doSetupPrimehack true
				else
					setSetting doSetupPrimehack false
				fi
				if [[ "$emusToReset" == *"PCSX2-Legacy"* ]]; then
					setSetting doSetupPCSX2 true
				else
					setSetting doSetupPCSX2 false
				fi
				if [[ "$emusToReset" == *"PCSX2-QT"* ]]; then
					setSetting doSetupPCSX2QT true
				else
					setSetting doSetupPCSX2QT false
				fi
				if [[ "$emusToReset" == *"RPCS3"* ]]; then
					setSetting doSetupRPCS3 true
				else
					setSetting doSetupRPCS3 false
				fi
				if [[ "$emusToReset" == *"Citra"* ]]; then
					setSetting doSetupCitra true
				else
					setSetting doSetupCitra false
				fi
				if [[ "$emusToReset" == *"Dolphin"* ]]; then
					setSetting doSetupDolphin true
				else
					setSetting doSetupDolphin false
				fi
				if [[ "$emusToReset" == *"Duckstation"* ]]; then
					setSetting doSetupDuck true
				else
					setSetting doSetupDuck false
				fi
				if [[ "$emusToReset" == *"PPSSPP"* ]]; then
					setSetting doSetupPPSSPP true
				else
					setSetting doSetupPPSSPP false
				fi
				if [[ "$emusToReset" == *"mGBA"* ]]; then
					setSetting doSetupMGBA true
				else
					setSetting doSetupMGBA false
				fi
				if [[ "$emusToReset" == *"Yuzu"* ]]; then
					setSetting doSetupYuzu true
				else
					setSetting doSetupYuzu false
				fi
				if [[ "$emusToReset" == *"Ryujinx"* ]]; then
					setSetting doSetupRyujinx true
				else
					setSetting doSetupRyujinx false
				fi
				if [[ "$emusToReset" == *"Cemu"* ]]; then
					setSetting doSetupCemu true
				else
					setSetting doSetupCemu false
				fi
				if [[ "$emusToReset" == *"Xemu"* ]]; then
					setSetting doSetupXemu true
				else
					setSetting doSetupXemu false
				fi
				if [[ "$emusToReset" == *"Xenia"* ]]; then
					setSetting doSetupXenia true #false until we add above
				else
					setSetting doSetupXenia false
				fi
				#if [[ "$emusToReset" == *"MelonDS"* ]]; then
				#	setSetting doSetupMelonDS true
				#else
				#	setSetting doSetupRA false
				#fi
				if [[ "$emusToReset" == *"Steam Rom Manager"* ]]; then
					setSetting doSetupSRM true
				else
					setSetting doSetupSRM false
				fi
				if [[ "$emusToReset" == *"EmulationStation DE"* ]]; then
					setSetting doSetupESDE true
				else
					setSetting doSetupESDE false
				fi
			
			
			else
				echo ""
			fi
			
		fi
	fi
else
	echo "Applying Easy mode Settings"
	#easy mode settings
	setSetting doInstallRA true
	setSetting doInstallDolphin true
	setSetting doInstallPCSX2 false
	setSetting doInstallPCSX2QT true
	setSetting doInstallRPCS3 true
	setSetting doInstallYuzu true
	setSetting doInstallRyujinx false
	setSetting doInstallCitra true
	setSetting doInstallDuck true
	setSetting doInstallCemu true
	setSetting doInstallPrimeHack true
	setSetting doInstallPPSSPP true
	setSetting doInstallXemu true
	setSetting doInstallMAME true
	setSetting doInstallXenia false
	setSetting doInstallMGBA false
	setSetting doInstallRMG true
	#doInstallMelon=true

	setSetting doSetupRA true
	setSetting doSetupPrimehack true
	setSetting doSetupDolphin true
	setSetting doSetupPCSX2 false
	setSetting doSetupPCSX2QT true
	setSetting doSetupRPCS3 true
	setSetting doSetupCitra true
	setSetting doSetupDuck true
	setSetting doSetupYuzu true
	setSetting doSetupRyujinx false
	setSetting doSetupPPSSPP true
	setSetting doSetupXemu true
	setSetting doSetupMAME true
	setSetting doSetupCemu true
	setSetting doSetupXenia false
	setSetting doSetupMGBA false
	setSetting doSetupRMG true

	#widescreen off by default
	setSetting duckWide false
	setSetting DolphinWide false
	setSetting DreamcastWide false
	setSetting BeetleWide false
	setSetting XemuWide false
	setSetting PCSX2QTWide false	

fi # end Expert if