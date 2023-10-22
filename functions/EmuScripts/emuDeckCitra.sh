#!/bin/bash
#variables
Citra_emuName="Citra"
Citra_emuType="FlatPak"
Citra_emuPath="org.citra_emu.citra"
Citra_releaseURL=""
Citra_configFile="$HOME/.var/app/org.citra_emu.citra/config/citra-emu/qt-config.ini"

#cleanupOlderThings
Citra_finalize(){
 echo "NYI"
}

#Install
Citra_install(){
	setMSG "Installing $Citra_emuName"
	installEmuFP "${Citra_emuName}" "${Citra_emuPath}"
	flatpak override "${Citra_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
Citra_init(){
	setMSG "Initializing $Citra_emuName settings."
	configEmuFP "${Citra_emuName}" "${Citra_emuPath}" "true"
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	Citra_addSteamInputProfile
}

#update
Citra_update(){
	setMSG "Updating $Citra_emuName settings."
	configEmuFP "${Citra_emuName}" "${Citra_emuPath}"
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	Citra_addSteamInputProfile
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
