#!/bin/bash
#variables
Azahar_emuName="Azahar"
Azahar_emuType="$emuDeckEmuTypeAppImage"
Azahar_emuPath="$emusFolder/azahar-gui.AppImage"
Azahar_releaseURL=""
Azahar_configFile="$HOME/.config/azahar-emu/qt-config.ini"
Azahar_configPath="$HOME/.config/azahar-emu"
Azahar_texturesPath="$HOME/.config/azahar-emu/load/textures"

#Install
Azahar_install(){
	echo "Begin $Azahar_emuName Install"
	local showProgress="$1"
	#local url=$(getReleaseURLGH "Azahar/azahar-archive" "tar.gz" "")
	local url="https://github.com/azahar-emu/azahar/releases/download/2120-rc3/azahar-2120-rc3-linux-appimage.tar.gz"
	if installEmuAI "$Azahar_emuName" "" "$url" "azahar" "tar.gz" "emulator" "$showProgress"; then #azahar-gui.AppImage
		mkdir "$emusFolder/azahar-temp"
		tar -xvzf "$emusFolder/azahar.tar.gz" -C "$emusFolder/azahar-temp" --strip-components 1
		if [ -f "$emusFolder/azahar-temp/azahar-gui.AppImage" ]; then
			mv "$emusFolder/azahar-temp/azahar-gui.AppImage" "$Azahar_emuPath"
		elif [ -f "$emusFolder/azahar-temp/azahar.AppImage" ]; then
			mv "$emusFolder/azahar-temp/azahar.AppImage" "$Azahar_emuPath"
		else
			rm -rf "$emusFolder/azahar-temp"
			rm -rf "$emusFolder/azahar.tar.gz"
			return 1
		fi
		chmod +x "$emusFolder/azahar-gui.AppImage"
		rm -rf "$emusFolder/azahar-temp"
		rm -rf "$emusFolder/azahar.tar.gz"
	else
		return 1
	fi
}

#ApplyInitialSettings
Azahar_init(){
	setMSG "Initializing $Azahar_emuName settings."
	configEmuAI "$Azahar_emuName" "azahar-emu"  "$Azahar_configPath" "$emudeckBackend/configs/azahar" "true"
	Azahar_setEmulationFolder
	Azahar_setupStorage
	Azahar_setupSaves
	Azahar_addSteamInputProfile
	Azahar_flushEmulatorLauncher
	Azahar_setupTextures
	Azahar_addParser
	Azahar_migrate

	#ESDE
	ESDE_refreshCustomEmus

	ESDE_setEmu 'Azahar (Standalone)' n3ds

}


#update
Azahar_update(){
	setMSG "Updating $Azahar_emuName settings."
	configEmuAI "$Azahar_emuName" "azahar-emu"  "$Azahar_configPath" "$emudeckBackend/configs/azahar"
	Azahar_setupStorage
	Azahar_setEmulationFolder
	Azahar_setupSaves
	Azahar_addSteamInputProfile
	Azahar_flushEmulatorLauncher
	Azahar_setupTextures
}

Azahar_setupStorage(){
	mkdir -p "$storagePath/azahar/"

	if [ ! -d "$storagePath/azahar/sdmc" ] && [ ! -d "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/sdmc" -o ! -d "$HOME/.local/share/azahar-emu" ] && [ -d "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" -o -d "$HOME/.local/share/citra-emu/sdmc" -o -d "$storagePath/citra/sdmc" ]; then
		echo "Azahar SDMC does not exist in storage path and does not exist in the original Flatpak or AppImage paths. Citra SDMC folder found, copying Citra SDMC folder."

		echo -e ""
		setMSG "Copying Citra SDMC to the Azahar SDMC folder"
		echo -e ""

		mkdir -p "$storagePath/azahar"


		if [ -d "$storagePath/citra/sdmc" ]; then
			rsync -av  --ignore-existing "$storagePath/citra/sdmc" "$storagePath"/azahar
		elif [ -d "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" ]; then
			rsync -av --ignore-existing "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc" "$storagePath"/azahar
		elif [ -d "$HOME/.local/share/citra-emu/sdmc" ]; then
			rsync -av  --ignore-existing "$HOME/.local/share/citra-emu/sdmc" "$storagePath"/azahar
		else
			mkdir -p "$storagePath/citra/sdmc"
		fi

	fi

	if [ ! -d "$storagePath/azahar/sdmc" ] && [ -d "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/sdmc" -o -d "$HOME/.local/share/azahar-emu/sdmc" ]; then
		echo "Azahar SDMC does not exist in storage path. Found Azahar SDMC in original path, copying to storage folder."

		echo -e ""
		setMSG "Copying Azahar SDMC to the Emulation/storage folder"
		echo -e ""

		mkdir -p "$storagePath/azahar"

		if [ -d "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/sdmc" ]; then
			rsync -av  --ignore-existing "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/sdmc" "$storagePath"/azahar/ && rm -rf "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/sdmc"

		elif [ -d "$HOME/.local/share/azahar-emu/sdmc" ]; then
			rsync -av  --ignore-existing "$HOME/.local/share/azahar-emu/sdmc" "$storagePath"/azahar/ && rm -rf "$HOME/.local/share/azahar-emu/sdmc"
		else
			mkdir -p "$storagePath/azahar/sdmc"
		fi
	else
		echo "Azahar SDMC does not exist anywhere. Creating SDMC folder."
		mkdir -p "$storagePath/azahar/sdmc"
	fi


	if [ ! -d "$storagePath/azahar/nand" ] && [ ! -d "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/nand" -o ! -d "$HOME/.local/share/azahar-emu" ] && [ -d "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/nand" -o -d "$HOME/.local/share/citra-emu/nand" -o -d "$storagePath/citra/nand" ]; then
		echo "Azahar NAND does not exist in storage path and does not exist in the original Flatpak or AppImage paths. Citra NAND folder found, copying Citra NAND folder."

		echo -e ""
		setMSG "Copying Citra NAND to the Azahar folder"
		echo -e ""

		mkdir -p "$storagePath/azahar"


		if [ -d "$storagePath/citra/nand" ]; then
			rsync -av  --ignore-existing "$storagePath/citra/nand" "$storagePath"/azahar
		elif [ -d "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/nand" ]; then
			rsync -av  --ignore-existing "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/nand" "$storagePath"/azahar
		elif [ -d "$HOME/.local/share/citra-emu/nand" ]; then
			rsync -av  --ignore-existing "$HOME/.local/share/citra-emu/nand" "$storagePath"/azahar
		else
			mkdir -p "$storagePath/citra/nand"
		fi

	fi


	if [ ! -d "$storagePath/azahar/nand" ] && [ -d "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/nand" -o -d "$HOME/.local/share/azahar-emu/nand" ]; then
		echo "Azahar NAND does not exist in storage path. Found Azahar NAND in original path, copying to storage folder."

		echo -e ""
		setMSG "Copying Citra NAND to the Azahar NAND folder"
		echo -e ""

		mkdir -p "$storagePath/azahar"

		if [ -d "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/nand" ]; then
			rsync -av  --ignore-existing "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/nand" "$storagePath"/azahar/ && rm -rf "$HOME/.var/app/io.github.azahar.Azahar/data/azahar-emu/nand"

		elif [ -d "$HOME/.local/share/azahar-emu/nand" ]; then
			rsync -av  --ignore-existing "$HOME/.local/share/azahar-emu/nand" "$storagePath"/azahar/ && rm -rf "$HOME/.local/share/azahar-emu/nand"
		else
			mkdir -p "$storagePath/azahar/nand"
		fi
	else
		echo "Azahar NAND does not exist anywhere. Creating NAND folder."
		mkdir -p "$storagePath/azahar/nand"
	fi



	# Cheats and Texture Packs
	# Cheats
	mkdir -p "$HOME/.local/share/azahar-emu/cheats"
	linkToStorageFolder azahar cheats "$HOME/.local/share/azahar-emu/cheats"
	# Texture Pack
	mkdir -p "$HOME/.local/share/azahar-emu/load/textures"
	linkToStorageFolder azahar textures "$HOME/.local/share/azahar-emu/load/textures"
}

#ConfigurePaths
Azahar_setEmulationFolder(){
	setMSG "Setting $Azahar_emuName Emulation Folder"

	mkdir -p "$Azahar_configPath"
	gameDirOpt='Paths\\gamedirs\\3\\path='
	newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/n3ds"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Azahar_configFile"

	nandDirOpt='nand_directory='
	newnandDirOpt='nand_directory='"$storagePath/azahar/nand/"
	sed -i "/${nandDirOpt}/c\\${newnandDirOpt}" "$Azahar_configFile"

	sdmcDirOpt='sdmc_directory='
	newsdmcDirOpt='sdmc_directory='"$storagePath/azahar/sdmc/"
	sed -i "/${sdmcDirOpt}/c\\${newsdmcDirOpt}" "$Azahar_configFile"

	mkdir -p "$storagePath/azahar/screenshots/"
	screenshotsDirOpt='Paths\\screenshotPath='
	newscreenshotDirOpt='Paths\\screenshotPath='"$storagePath/azahar/screenshots/"
	sed -i "/${screenshotsDirOpt}/c\\${newscreenshotDirOpt}" "$Azahar_configFile"

	# True/False configs
	sed -i 's/nand_directory\\default=true/nand_directory\\default=false/' "$Azahar_configFile"
	sed -i 's/sdmc_directory\\default=true/sdmc_directory\\default=false/' "$Azahar_configFile"
	sed -i 's/use_custom_storage=false/use_custom_storage=true/' "$Azahar_configFile"
	sed -i 's/use_custom_storage\\default=true/use_custom_storage\\default=false/' "$Azahar_configFile"

	# Vulkan Graphics
	sed -E 's/layout_option=[0-9]+/layout_option=5/g' "$Azahar_configFile"
	sed -i 's/layout_option\\default=true/layout_option\\default=false/' "$Azahar_configFile"

	#Setup symlink for AES keys
	mkdir -p "${biosPath}/azahar/"
	mkdir -p "$HOME/.local/share/azahar-emu/sysdata"
	ln -sn "$HOME/.local/share/azahar-emu/sysdata" "${biosPath}/azahar/keys"

}



#SetupSaves
Azahar_setupSaves(){
	mkdir -p "$HOME/.local/share/azahar-emu/states"
	linkToSaveFolder azahar saves "$storagePath/azahar/sdmc"
	linkToSaveFolder azahar states "$HOME/.local/share/azahar-emu/states"
}

#Set up textures

Azahar_setupTextures(){
	mkdir -p "$HOME/.local/share/azahar-emu/load/textures"
	linkToTexturesFolder azahar textures "$HOME/.local/share/azahar-emu/load/textures"

}

#WipeSettings
Azahar_wipe(){
	setMSG "Wiping $Azahar_emuName config directory. (factory reset)"
	rm -rf "$HOME/.config/azahar-emu"
}


#Uninstall
Azahar_uninstall(){
	setMSG "Uninstalling $Azahar_emuName."
	removeParser "nintendo_3ds_azahar.json"
	uninstallEmuAI $Azahar_emuName "azahar-gui" "" "emulator"
}

#setABXYstyle
Azahar_setABXYstyle(){
	sed -i '/button_a/s/button:1/button:0/' "$Azahar_configFile"
	sed -i '/button_b/s/button:0/button:1/' "$Azahar_configFile"
	sed -i '/button_x/s/button:3/button:2/' "$Azahar_configFile"
	sed -i '/button_y/s/button:2/button:3/' "$Azahar_configFile"

}

Azahar_setBAYXstyle(){
	sed -i '/button_a/s/button:0/button:1/' "$Azahar_configFile"
	sed -i '/button_b/s/button:1/button:0/' "$Azahar_configFile"
	sed -i '/button_x/s/button:2/button:3/' "$Azahar_configFile"
	sed -i '/button_y/s/button:3/button:2/' "$Azahar_configFile"
}

#finalExec - Extra stuff
Azahar_finalize(){
	echo "NYI"
}

Azahar_IsInstalled(){
	if [ -e "$Azahar_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Azahar_resetConfig(){
	Azahar_init &>/dev/null && echo "true" || echo "false"
}

Azahar_addSteamInputProfile(){
	addSteamInputCustomIcons
	setMSG "Adding $Azahar_emuName Steam Input Profile."
	#rsync -r "$emudeckBackend/configs/steam-input/Azahar_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
	rsync -r --exclude='*/' "$emudeckBackend/configs/steam-input/" "$HOME/.steam/steam/controller_base/templates/"
}

Azahar_setResolution(){
	case $azaharResolution in
		"720P") multiplier=3;;
		"1080P") multiplier=5;;
		"1440P") multiplier=6;;
		"4K") multiplier=9;;
		*) echo "Error"; return 1;;
	esac

	setConfig "resolution_factor" $multiplier "$Azahar_configFile"
}

Azahar_flushEmulatorLauncher(){


	flushEmulatorLaunchers "azahar"

}


Azahar_addParser(){
	addParser "nintendo_3ds_azahar.json"
}

Azahar_migrate(){
	rm -rf "$toolsPath/launchers/citra.sh"
	rm -rf "$toolsPath/launchers/lime3ds.sh"

	simLinkPath="$toolsPath/launchers/lime3ds.sh"
	emuSavePath="$toolsPath/launchers/azahar.sh"
	ln -sf $emuSavePath $simLinkPath

	simLinkPath="$toolsPath/launchers/citra.sh"
	emuSavePath="$toolsPath/launchers/azahar.sh"
	ln -sf $emuSavePath $simLinkPath
}