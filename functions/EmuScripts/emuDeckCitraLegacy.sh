#!/bin/bash
#variables
Citra_emuName="Citra"
Citra_emuType="FlatPak"
Citra_emuPath="org.citra_emu.citra"
Citra_releaseURL=""
Citra_configFile="$HOME/.var/app/org.citra_emu.citra/config/citra-emu/qt-config.ini"
Citra_texturesPath="$HOME/.var/app/$Citra_emuPath/data/citra-emu/load/textures"

#cleanupOlderThings
Citra_finalize(){
 echo "NYI"
}

#Install
Citra_install(){
	setMSG "Installing $Citra_emuName"
	installEmuFP "${Citra_emuName}" "${Citra_emuPath}"
}

#ApplyInitialSettings
Citra_init(){
	setMSG "Initializing $Citra_emuName settings."
	configEmuFP "${Citra_emuName}" "${Citra_emuPath}" "true"
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	#SRM_createParsers
	#Citra_addSteamInputProfile
}

#update
Citra_update(){
	setMSG "Updating $Citra_emuName settings."
	configEmuFP "${Citra_emuName}" "${Citra_emuPath}"
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	#Citra_addSteamInputProfile
}

#ConfigurePaths
Citra_setEmulationFolder(){
	setMSG "Setting $Citra_emuName Emulation Folder"

	gameDirOpt='Paths\\gamedirs\\3\\path='
	newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/3ds"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Citra_configFile"

	#Setup symlink for AES keys
	mkdir -p "${biosPath}/citra/"
	mkdir -p "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sysdata"
	ln -sn "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sysdata" "${biosPath}/citra/keys"
}

#SetupSaves
Citra_setupSaves(){
	linkToSaveFolder citra saves "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc"
	linkToSaveFolder citra states "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/states"
}


#SetupStorage
Citra_setupStorage(){

	if [ -d "${HOME}/.local/share/Steam" ]; then
		STEAMPATH="${HOME}/.local/share/Steam"
	elif [ -d "${HOME}/.steam/steam" ]; then
		STEAMPATH="${HOME}/.steam/steam"
	else
		echo "Steam install not found"
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
	find "$STEAMPATH/userdata" -name "shortcuts.vdf" -exec sed -i "s|${romsPath}/n3ds|${romsPath}/3ds|g" {} +


	local textureLink="$(readlink -f "$Citra_texturesPath")"
	if [[ "$textureLink" != "$emulationPath/hdpacks/3ds" ]]; then
		rm -rf "$Citra_texturesPath"
		ln -s "$Citra_texturesPath" "$emulationPath/hdpacks/3ds"
	fi


	if [ ! -f "$storagePath/citra/nand" ] && [ -d "$HOME/.var/app/org.ctira_emu.citra/data/citra-emu/nand/" ]; then

		echo "citra nand does not exist in storagepath."
		echo -e ""
		setMSG "Moving Citra nand to the Emulation/storage folder"
		echo -e ""

		mv "$HOME/.var/app/org.ctira_emu.citra/data/citra-emu/nand/" $storagePath/citra/nand/
		mv "$HOME/.var/app/org.ctira_emu.citra/data/citra-emu/sdmc/" $storagePath/citra/sdmc/

		unlink "$HOME/.var/app/org.ctira_emu.citra/data/citra-emu/nand/"
		unlink "$HOME/.var/app/org.ctira_emu.citra/data/citra-emu/sdmc/"

		ln -ns "${storagePath}/citra/nand/" "$HOME/.var/app/org.ctira_emu.citra/data/citra-emu/nand/"
		ln -ns "${storagePath}/citra/sdmc/" "$HOME/.var/app/org.ctira_emu.citra/data/citra-emu/sdmc/"
	fi

}


#WipeSettings
Citra_wipe(){
	setMSG "Wiping $Citra_emuName config directory. (factory reset)"
	rm -rf "$HOME/.var/app/$Citra_emuPath"
}


#Uninstall
Citra_uninstall(){
	setMSG "Uninstalling $Citra_emuName."
	flatpak uninstall "$Citra_emuPath" --user -y
}

#setABXYstyle
Citra_setABXYstyle(){
		echo "NYI"
}

#Migrate
Citra_migrate(){
echo "NYI"
}

#WideScreenOn
Citra_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Citra_wideScreenOff(){
echo "NYI"
}

#BezelOn
Citra_bezelOn(){
echo "NYI"
}

#BezelOff
Citra_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Citra_finalize(){
	echo "NYI"
}

Citra_IsInstalled(){
	isFpInstalled "$Citra_emuPath"
}

Citra_resetConfig(){
	Citra_init &>/dev/null && echo "true" || echo "false"
}

Citra_addSteamInputProfile(){
	addSteamInputCustomIcons
	rsync -r "$EMUDECKGIT/configs/steam-input/citra_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
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