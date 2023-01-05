#!/bin/bash
#variables
MelonDS_emuName="MelonDS"
MelonDS_emuType="FlatPak"
MelonDS_emuPath="net.kuribo64.melonDS"
MelonDS_releaseURL=""
MelonDS_configFile="$HOME/.var/app/net.kuribo64.melonDS/config/melonDS/melonDS.ini"

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
}

#update
MelonDS_update(){
	setMSG "Updating $MelonDS_emuName settings."	
	configEmuFP "${MelonDS_emuName}" "${MelonDS_emuPath}"
	MelonDS_setupStorage
	MelonDS_setEmulationFolder
	MelonDS_setupSaves
}

#ConfigurePaths
MelonDS_setEmulationFolder(){
	setMSG "Setting $MelonDS_emuName Emulation Folder"	

	BIOS9PathSetting='BIOS9Path='
	BIOS7PathSetting='BIOS7Path='
	FirmwarePathSetting='FirmwarePath='
	DSiBIOS9PathSetting='DSiBIOS9Path='
	DSiBIOS7PathSetting='DSiBIOS7Path='
	DSiFirmwarePathSetting='DSiFirmwarePath='
	DSiNANDPathSetting='DSiNANDPath='
	LastROMFolderSetting='LastROMFolder='

	changeLine "$BIOS9PathSetting" "${BIOS9PathSetting}${biosPath}/bios9.bin" "${MelonDS_configFile}"
	changeLine "$BIOS7PathSetting" "${BIOS7PathSetting}${biosPath}/bios7.bin" "${MelonDS_configFile}"
	changeLine "$FirmwarePathSetting" "${FirmwarePathSetting}${biosPath}/firmware.bin" "${MelonDS_configFile}"
	changeLine "$DSiBIOS9PathSetting" "${DSiBIOS9PathSetting}${biosPath}/dsi_bios9.bin" "${MelonDS_configFile}"
	changeLine "$DSiBIOS7PathSetting" "${DSiBIOS7PathSetting}${biosPath}/dsi_bios7.bin" "${MelonDS_configFile}"
	changeLine "$DSiFirmwarePathSetting" "${DSiFirmwarePathSetting}${biosPath}/dsi_firmware.bin" "${MelonDS_configFile}"
	changeLine "$DSiNANDPathSetting" "${DSiNANDPathSetting}${biosPath}/dsi_nand.bin" "${MelonDS_configFile}"
	changeLine "$LastROMFolderSetting" "${LastROMFolderSetting}${romsPath}/nds" "${MelonDS_configFile}"

}

#SetupSaves
MelonDS_setupSaves(){
	setMSG "Setting $MelonDS_emuName Saves Folder"	

	mkdir -p "${savesPath}/melonds/saves"
	mkdir -p "${savesPath}/melonds/states"
	
	SaveFilePathSetting='SaveFilePath='
	SavestatePathSetting='SavestatePath='

	changeLine "$SaveFilePathSetting" "${SaveFilePathSetting}${savesPath}/melonds/saves" "${MelonDS_configFile}"
	changeLine "$SavestatePathSetting" "${SavestatePathSetting}${savesPath}/melonds/states" "${MelonDS_configFile}"
	
}


#SetupStorage
MelonDS_setupStorage(){
	setMSG "Setting $MelonDS_emuName Storage Folder"	

	mkdir -p "$storagePath/melonDS/cheats"

	CheatFilePathSetting='CheatFilePath='

	changeLine "$CheatFilePathSetting" "${CheatFilePathSetting}${storagePath}/melonds/cheats" "${MelonDS_configFile}"
	
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
decho "NYI"
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
	echo "nyi"
}
