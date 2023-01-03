#!/bin/bash
#variables
MelonDS_emuName="MelonDS"
MelonDS_emuType="FlatPak"
MelonDS_emuPath="net.kuribo64.melonDS"
MelonDS_releaseURL=""
MelonDS_configFile="$HOME/.var/app/net.kuribo64.melonDS/config/MelonDS/melonDS.ini"

#cleanupOlderThings
MelonDS_finalize(){
 echo "NYI"
}

#Install
MelonDS_install(){
	setMSG "Installing $MelonDS_emuName"	
	installEmuFP "${MelonDS_emuName}" "${MelonDS_emuPath}"	
	flatpak override "${MelonDS_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
MelonDS_init(){
	setMSG "Initializing $MelonDS_emuName settings."	
	configEmuFP "${MelonDS_emuName}" "${MelonDS_emuPath}" "true"
	MelonDS_setupStorage
	MelonDS_setEmulationFolder
	MelonDS_setupSaves
	MelonDS_addSteamInputProfile
}

#update
MelonDS_update(){
	setMSG "Updating $MelonDS_emuName settings."	
	configEmuFP "${MelonDS_emuName}" "${MelonDS_emuPath}"
	MelonDS_setupStorage
	MelonDS_setEmulationFolder
	MelonDS_setupSaves
	MelonDS_addSteamInputProfile
}

#ConfigurePaths
MelonDS_setEmulationFolder(){
	setMSG "Setting $MelonDS_emuName Emulation Folder"	

    gameDirOpt='Paths\\gamedirs\\3\\path='
    newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/3ds"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$MelonDS_configFile"

	#Setup symlink for AES keys
	mkdir -p "${biosPath}/MelonDS/"
	mkdir -p "$HOME/.var/app/org.MelonDS_emu.MelonDS/data/MelonDS-emu/sysdata"
    ln -sn "$HOME/.var/app/org.MelonDS_emu.MelonDS/data/MelonDS-emu/sysdata" "${biosPath}/MelonDS/keys"
}

#SetupSaves
MelonDS_setupSaves(){
	linkToSaveFolder MelonDS saves "$HOME/.var/app/org.MelonDS_emu.MelonDS/data/MelonDS-emu/sdmc"
	linkToSaveFolder MelonDS states "$HOME/.var/app/org.MelonDS_emu.MelonDS/data/MelonDS-emu/states"
}


#SetupStorage
MelonDS_setupStorage(){

	if [ ! -f "$storagePath/MelonDS/nand" ] && [ -d "$HOME/.var/app/org.ctira_emu.MelonDS/data/MelonDS-emu/nand/" ]; then 

		echo "MelonDS nand does not exist in storagepath."
		echo -e ""
		setMSG "Moving MelonDS nand to the Emulation/storage folder"			
		echo -e ""

		mv "$HOME/.var/app/org.ctira_emu.MelonDS/data/MelonDS-emu/nand/" $storagePath/MelonDS/nand/
		mv "$HOME/.var/app/org.ctira_emu.MelonDS/data/MelonDS-emu/sdmc/" $storagePath/MelonDS/sdmc/	
	
		unlink "$HOME/.var/app/org.ctira_emu.MelonDS/data/MelonDS-emu/nand/"
		unlink "$HOME/.var/app/org.ctira_emu.MelonDS/data/MelonDS-emu/sdmc/" 
	
		ln -ns "${storagePath}/MelonDS/nand/" "$HOME/.var/app/org.ctira_emu.MelonDS/data/MelonDS-emu/nand/"
		ln -ns "${storagePath}/MelonDS/sdmc/" "$HOME/.var/app/org.ctira_emu.MelonDS/data/MelonDS-emu/sdmc/"
	fi

}


#WipeSettings
MelonDS_wipe(){
	setMSG "Wiping $MelonDS_emuName config directory. (factory reset)"
	rm -rf "$HOME/.var/app/$MelonDS_emuPath"
}


#Uninstall
MelonDS_uninstall(){
	setMSG "Uninstalling $MelonDS_emuName."
    flatpak uninstall "$MelonDS_emuPath" --user -y
}

#setABXYstyle
MelonDS_setABXYstyle(){
    	echo "NYI"
}

#Migrate
MelonDS_migrate(){
echo "NYI"
}

#WideScreenOn
MelonDS_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
MelonDS_wideScreenOff(){
echo "NYI"
}

#BezelOn
MelonDS_bezelOn(){
echo "NYI"
}

#BezelOff
MelonDS_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
MelonDS_finalize(){
	echo "NYI"
}

MelonDS_IsInstalled(){
	if [ "$(flatpak --columns=app list | grep "$MelonDS_emuPath")" == "$MelonDS_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

MelonDS_resetConfig(){
	MelonDS_init &>/dev/null && echo "true" || echo "false"
}

MelonDS_addSteamInputProfile(){
	rsync -r "$EMUDECKGIT/configs/steam-input/MelonDS_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
