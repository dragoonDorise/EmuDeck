#!/bin/bash
#variables
Citra_emuName="Citra"
Citra_emuType="$emuDeckEmuTypeAppImage"
Citra_emuPath="$HOME/Applications/citra-qt.AppImage"
Citra_releaseURL=""
Citra_configFile="$HOME/.config/citra-emu/qt-config.ini"
Citra_configPath="$HOME/.config/citra-emu"
Citra_texturesPath="$HOME/.config/citra-emu/load/textures"

#Install
Citra_install(){
	echo "Begin $Citra_emuName Install"
	local showProgress="$1"
	if installEmuAI "$Citra_emuName" "" "$(getReleaseURLGH "PabloMK7/citra" "tar.gz" "" "appimage")" "citra" "tar.gz" "emulator" "$showProgress"; then #citra-qt.AppImage
		mkdir "$HOME/Applications/citra-temp"
		tar -xvzf "$HOME/Applications/citra.tar.gz" -C "$HOME/Applications/citra-temp" --strip-components 1
		mv "$HOME/Applications/citra-temp/citra-qt.AppImage" "$HOME/Applications"
		rm -rf "$HOME/Applications/citra-temp"
		rm -rf "$HOME/Applications/citra.tar.gz"
		chmod +x "$HOME/Applications/citra-qt.AppImage"
	else
		return 1
	fi
}

#ApplyInitialSettings
Citra_init(){
	setMSG "Initializing $Citra_emuName settings."
	configEmuAI "$Citra_emuName" "citra-emu"  "$HOME/.config/citra-emu" "$EMUDECKGIT/configs/citra-emu" "true"
	Citra_setEmulationFolder
	Citra_setupStorage
	Citra_setupSaves
	Citra_addSteamInputProfile
	Citra_flushEmulatorLauncher
	Citra_flushSymlinks
	Citra_setupTextures
}

#update
Citra_update(){
	setMSG "Updating $Citra_emuName settings."
	configEmuAI "$Citra_emuName" "citra-emu" "$HOME/.config/citra-emu" "$EMUDECKGIT/configs/citra-emu"
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	Citra_addSteamInputProfile
	Citra_flushEmulatorLauncher
	Citra_flushSymlinks
	Citra_setupTextures
}

Citra_setupStorage(){
	mkdir -p "$storagePath/citra/"


	# SDMC and NAND
	if [ ! -d "$storagePath/citra/sdmc" ] && [ -d "$HOME/.var/app/org.citra_emu.citra" -o -d "$HOME/.local/share/citra-emu" ]; then
		echo "Citra SDMC does not exist in storage path"

		echo -e ""
		setMSG "Moving Citra SDMC to the Emulation/storage folder"
		echo -e ""

		mkdir -p "$storagePath/citra"

		if [ -d "$savesPath/citra/sdmc" ]; then
			mv -f "$savesPath"/citra/sdmc "$storagePath"/citra/

		elif [ -d "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" ]; then
			rsync -av "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" "$storagePath"/citra/ && rm -rf "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc"

		elif [ -d "$HOME/.local/share/citra-emu/sdmc" ]; then
			rsync -av "$HOME/.local/share/citra-emu/sdmc" "$storagePath"/citra/ && rm -rf "$HOME/.local/share/citra-emu/sdmc"
		else 
			mkdir -p "$storagePath/citra/sdmc"
		fi
	else 
		mkdir -p "$storagePath/citra/sdmc"
	fi


	if [ ! -d "$storagePath/citra/nand" ] && [ -d "$HOME/.var/app/org.citra_emu.citra" -o -d "$HOME/.local/share/citra-emu" ]; then
		echo "Citra NAND does not exist in storage path"

		echo -e ""
		setMSG "Moving Citra NAND to the Emulation/storage folder"
		echo -e ""

		mkdir -p "$storagePath/citra"

		if [ -d "$savesPath/citra/nand" ]; then
			mv -f "$savesPath"/citra/nand "$storagePath"/citra/

		elif [ -d "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/nand" ]; then
			rsync -av "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/nand" "$storagePath"/citra/ && rm -rf "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/nand"

		elif [ -d "$HOME/.local/share/citra-emu/nand" ]; then
			rsync -av "$HOME/.local/share/citra-emu/nand" "$storagePath"/citra/ && rm -rf "$HOME/.local/share/citra-emu/nand"
		else 
			mkdir -p "$storagePath/citra/nand"
		fi
	else 
		mkdir -p "$storagePath/citra/nand"
	fi

	# Cheats and Texture Packs
	# Cheats
	mkdir -p "$HOME/.local/share/citra-emu/cheats"
	linkToStorageFolder citra cheats "$HOME/.local/share/citra-emu/cheats"
	# Texture Pack
	mkdir -p "$HOME/.local/share/citra-emu/load/textures"
	linkToStorageFolder citra textures "$HOME/.local/share/citra-emu/load/textures"
}

#ConfigurePaths
Citra_setEmulationFolder(){
	setMSG "Setting $Citra_emuName Emulation Folder"

	mkdir -p "$Citra_configPath"
	gameDirOpt='Paths\\gamedirs\\3\\path='
	newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/n3ds"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Citra_configFile"

	nandDirOpt='nand_directory='
	newnandDirOpt='nand_directory='"$storagePath/citra/nand/"
	sed -i "/${nandDirOpt}/c\\${newnandDirOpt}" "$Citra_configFile"

	sdmcDirOpt='sdmc_directory='
	newsdmcDirOpt='sdmc_directory='"$storagePath/citra/sdmc/"
	sed -i "/${sdmcDirOpt}/c\\${newsdmcDirOpt}" "$Citra_configFile"

	mkdir -p "$storagePath/citra/screenshots/"
	screenshotsDirOpt='Paths\\screenshotPath='
	newscreenshotDirOpt='Paths\\screenshotPath='"$storagePath/citra/screenshots/"
	sed -i "/${screenshotsDirOpt}/c\\${newscreenshotDirOpt}" "$Citra_configFile"

	# True/False configs
	sed -i 's/nand_directory\\default=true/nand_directory\\default=false/' "$Citra_configFile"
	sed -i 's/sdmc_directory\\default=true/sdmc_directory\\default=false/' "$Citra_configFile"
	sed -i 's/use_custom_storage=false/use_custom_storage=true/' "$Citra_configFile"
	sed -i 's/use_custom_storage\\default=true/use_custom_storage\\default=false/' "$Citra_configFile"

	# Vulkan Graphics
	sed -E 's/layout_option=[0-9]+/layout_option=5/g' "$Citra_configFile"
	sed -i 's/layout_option\\default=true/layout_option\\default=false/' "$Citra_configFile"

	#Setup symlink for AES keys
	mkdir -p "${biosPath}/citra/"
	mkdir -p "$HOME/.local/share/citra-emu/sysdata"
	ln -sn "$HOME/.local/share/citra-emu/sysdata" "${biosPath}/citra/keys"

}



#SetupSaves
Citra_setupSaves(){
	mkdir -p "$HOME/.local/share/citra-emu/states"
	linkToSaveFolder citra saves "$storagePath/citra/sdmc"
	linkToSaveFolder citra states "$HOME/.local/share/citra-emu/states"
}

#Set up textures

Citra_setupTextures(){
	mkdir -p "$HOME/.local/share/citra-emu/load/textures"
	linkToTexturesFolder citra textures "$HOME/.local/share/citra-emu/load/textures"
	
}

#WipeSettings
Citra_wipe(){
	setMSG "Wiping $Citra_emuName config directory. (factory reset)"
	rm -rf "$HOME/.config/citra-emu"
}


#Uninstall
Citra_uninstall(){
	setMSG "Uninstalling $Citra_emuName."
	uninstallEmuAI $Citra_emuName "citra-qt" "" "emulator"
}

#setABXYstyle
Citra_setABXYstyle(){
	sed -i '/button_a/s/button:1/button:0/' "$Citra_configFile"
	sed -i '/button_b/s/button:0/button:1/' "$Citra_configFile"
	sed -i '/button_x/s/button:3/button:2/' "$Citra_configFile"
	sed -i '/button_y/s/button:2/button:3/' "$Citra_configFile"

}

Citra_setBAYXstyle(){
	sed -i '/button_a/s/button:0/button:1/' "$Citra_configFile"
	sed -i '/button_b/s/button:1/button:0/' "$Citra_configFile"
	sed -i '/button_x/s/button:2/button:3/' "$Citra_configFile"
	sed -i '/button_y/s/button:3/button:2/' "$Citra_configFile"
}

#finalExec - Extra stuff
Citra_finalize(){
	echo "NYI"
}

Citra_IsInstalled(){
	if [ -e "$Citra_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Citra_resetConfig(){
	Citra_init &>/dev/null && echo "true" || echo "false"
}

Citra_addSteamInputProfile(){
	addSteamInputCustomIcons
	setMSG "Adding $Citra_emuName Steam Input Profile."
	#rsync -r "$EMUDECKGIT/configs/steam-input/citra_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
	rsync -r --exclude='*/' "$EMUDECKGIT/configs/steam-input/" "$HOME/.steam/steam/controller_base/templates/"
}

Citra_setResolution(){
	case $citraResolution in
		"720P") multiplier=3;;
		"1080P") multiplier=5;;
		"1440P") multiplier=6;;
		"4K") multiplier=9;;
		*) echo "Error"; return 1;;
	esac

	setConfig "resolution_factor" $multiplier "$Citra_configFile"
}

Citra_flushEmulatorLauncher(){


	flushEmulatorLaunchers "citra"

}

Citra_flushSymlinks(){


	if [ -d "${HOME}/.local/share/Steam" ]; then
		STEAMPATH="${HOME}/.local/share/Steam"
	elif [ -d "${HOME}/.steam/steam" ]; then
		STEAMPATH="${HOME}/.steam/steam"
	else
		echo "Steam install not found"
	fi

  	if [ ! -f "$HOME/.config/EmuDeck/.citralegacysymlinks" ] && [ -f "$HOME/.config/EmuDeck/.citrasymlinks" ]; then

		mkdir -p "$romsPath/n3ds"
    	# Temporary deletion to check if there are any additional contents in the n3ds folder.
		rm -rf "$romsPath/n3ds/media" &> /dev/null
		rm -rf "$romsPath/n3ds/metadata.txt" &> /dev/null
		rm -rf "$romsPath/n3ds/systeminfo.txt" &> /dev/null

		# The Pegasus install was accidentally overwriting the pre-existing n3ds symlink. 
		# This checks if the n3ds folder is empty (post-removing the contents above) and if the original 3ds folder is still a folder and not a symlink (for those who have already migrated). 
		# If all of this is true, the n3ds folder is deleted and the old symlink is temporarily recreated to proceed with the migration. 
		if [[ ! "$( ls -A "$romsPath/n3ds")" ]] && [ -d "$romsPath/3ds" ] && [ ! -L "$romsPath/3ds" ]; then
			rm -rf "$romsPath/n3ds"
			ln -sfn "$romsPath/3ds" "$romsPath/n3ds" 
      		# Temporarily restores old directory structure. 
		fi 

		if [[ -L "$romsPath/n3ds" && ! $(readlink -f "$romsPath/n3ds") =~ ^"$romsPath" ]] || [[ -L "$romsPath/3ds" && ! $(readlink -f "$romsPath/3ds") =~ ^"$romsPath" ]]; then
			echo "User has symlinks that don't match expected paths located under $romsPath. Aborting symlink update."
		else
			if [[ ! -e "$romsPath/3ds" && ! -e "$romsPath/n3ds" ]]; then
				mkdir -p "$romsPath/n3ds"
				ln -sfn "$romsPath/n3ds" "$romsPath/3ds"
			elif [[ -d "$romsPath/3ds" && -L "$romsPath/n3ds" ]]; then
				echo "Converting n3ds symlink to a regular directory..."
				unlink "$romsPath/n3ds"
				mv "$romsPath/3ds" "$romsPath/n3ds"
				ln -sfn "$romsPath/n3ds" "$romsPath/3ds"
				echo "3ds symlink updated to point to n3ds"
			elif [[ -d "$romsPath/3ds" && ! -e "$romsPath/n3ds" ]]; then
				echo "Creating n3ds directory and updating 3ds symlink..."
				mv "$romsPath/3ds" "$romsPath/n3ds"
				ln -sfn "$romsPath/n3ds" "$romsPath/3ds"
				echo "3ds symlink updated to point to n3ds"
			elif [[ -d "$romsPath/n3ds" && ! -e "$romsPath/3ds" ]]; then
				echo "3ds symlink not found, creating..."
				ln -sfn "$romsPath/n3ds" "$romsPath/3ds"
				echo "3ds symlink created"
			fi
		fi
		

		rsync -avh "$EMUDECKGIT/roms/n3ds/." "$romsPath/n3ds/." --ignore-existing

		if [ -d "$toolsPath/downloaded_media/n3ds" ] && [ ! -d "$romsPath/n3ds/media" ]; then 
			ln -s "$toolsPath/downloaded_media/n3ds" "$romsPath/n3ds/media"
		fi

    	find "$STEAMPATH/userdata" -name "shortcuts.vdf" -exec sed -i "s|${romsPath}/3ds|${romsPath}/n3ds|g" {} +
		touch "$HOME/.config/EmuDeck/.citralegacysymlinks"
		echo "Citra symlink cleanup completed."
		zenity --info \
		--text="Citra symlinks have been cleaned. This cleanup was conducted to prevent any potential breakage with symlinks. Place all new ROMs in Emulation/roms/n3ds. Your ROMs have been moved from Emulation/roms/3ds to Emulation/roms/n3ds." \
		--title="Symlink Update" \
		--width=400 \
		--height=300

	else
		echo "Citra symlinks already cleaned."
	fi


	if [ ! -f "$HOME/.config/EmuDeck/.citrasymlinks" ]; then


		mkdir -p "$romsPath/n3ds"
    	# Temporary deletion to check if there are any additional contents in the n3ds folder.
		rm -rf "$romsPath/n3ds/media" &> /dev/null
		rm -rf "$romsPath/n3ds/metadata.txt" &> /dev/null
		rm -rf "$romsPath/n3ds/systeminfo.txt" &> /dev/null

		# The Pegasus install was accidentally overwriting the pre-existing n3ds symlink. 
		# This checks if the n3ds folder is empty (post-removing the contents above) and if the original 3ds folder is still a folder and not a symlink (for those who have already migrated). 
		# If all of this is true, the n3ds folder is deleted and the old symlink is temporarily recreated to proceed with the migration. 
		if [[ ! "$( ls -A "$romsPath/n3ds")" ]] && [ -d "$romsPath/3ds" ] && [ ! -L "$romsPath/3ds" ]; then
			rm -rf "$romsPath/n3ds"
			ln -sfn "$romsPath/3ds" "$romsPath/n3ds" 
      		# Temporarily restores old directory structure. 
		fi 

		if [[ -L "$romsPath/n3ds" && ! $(readlink -f "$romsPath/n3ds") =~ ^"$romsPath" ]] || [[ -L "$romsPath/3ds" && ! $(readlink -f "$romsPath/3ds") =~ ^"$romsPath" ]]; then
			echo "User has symlinks that don't match expected paths located under $romsPath. Aborting symlink update."
		else
			if [[ ! -e "$romsPath/3ds" && ! -e "$romsPath/n3ds" ]]; then
				mkdir -p "$romsPath/n3ds"
				ln -sfn "$romsPath/n3ds" "$romsPath/3ds"
			elif [[ -d "$romsPath/3ds" && -L "$romsPath/n3ds" ]]; then
				echo "Converting n3ds symlink to a regular directory..."
				unlink "$romsPath/n3ds"
				mv "$romsPath/3ds" "$romsPath/n3ds"
				ln -sfn "$romsPath/n3ds" "$romsPath/3ds"
				echo "3ds symlink updated to point to n3ds"
			elif [[ -d "$romsPath/3ds" && ! -e "$romsPath/n3ds" ]]; then
				echo "Creating n3ds directory and updating 3ds symlink..."
				mv "$romsPath/3ds" "$romsPath/n3ds"
				ln -sfn "$romsPath/n3ds" "$romsPath/3ds"
				echo "3ds symlink updated to point to n3ds"
			elif [[ -d "$romsPath/n3ds" && ! -e "$romsPath/3ds" ]]; then
				echo "3ds symlink not found, creating..."
				ln -sfn "$romsPath/n3ds" "$romsPath/3ds"
				echo "3ds symlink created"
			fi
		fi

		rsync -avh "$EMUDECKGIT/roms/n3ds/." "$romsPath/n3ds/." --ignore-existing

		if [ -d "$toolsPath/downloaded_media/n3ds" ] && [ ! -d "$romsPath/n3ds/media" ]; then 
			ln -s "$toolsPath/downloaded_media/n3ds" "$romsPath/n3ds/media"
		fi

    	find "$STEAMPATH/userdata" -name "shortcuts.vdf" -exec sed -i "s|${romsPath}/3ds|${romsPath}/n3ds|g" {} +
		touch "$HOME/.config/EmuDeck/.citrasymlinks"
		echo "Citra symlink cleanup completed."
		zenity --info \
		--text="Citra symlinks have been cleaned. This cleanup was conducted to prevent any potential breakage with symlinks. Place all new ROMs in Emulation/roms/n3ds. Your ROMs have been moved from Emulation/roms/3ds to Emulation/roms/n3ds." \
		--title="Symlink Update" \
		--width=400 \
		--height=300

	else
		echo "Citra symlinks already cleaned."
	fi
}
