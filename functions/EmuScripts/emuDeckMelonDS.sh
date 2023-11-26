#!/bin/bash
#variables
melonDS_emuName="MelonDS"
melonDS_emuType="FlatPak"
melonDS_emuPath="net.kuribo64.melonDS"
melonDS_releaseURL=""
melonDS_configFile="$HOME/.var/app/net.kuribo64.melonDS/config/melonDS/melonDS.ini"

#cleanupOlderThings
melonDS_finalize(){
 echo "NYI"
}

#Install
melonDS_install(){
	setMSG "Installing $melonDS_emuName"
	installEmuFP "${melonDS_emuName}" "${melonDS_emuPath}"
	flatpak override "${melonDS_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
melonDS_init(){
	setMSG "Initializing $melonDS_emuName settings."
	configEmuFP "${melonDS_emuName}" "${melonDS_emuPath}" "true"
	melonDS_setupStorage
	melonDS_setEmulationFolder
	melonDS_setupSaves
	melonDS_addSteamInputProfile

}

#update
melonDS_update(){
	setMSG "Updating $melonDS_emuName settings."
	configEmuFP "${melonDS_emuName}" "${melonDS_emuPath}"
	melonDS_setupStorage
	melonDS_setEmulationFolder
	melonDS_setupSaves
	melonDS_addSteamInputProfile

}

#ConfigurePaths
melonDS_setEmulationFolder(){
	setMSG "Setting $melonDS_emuName Emulation Folder"

	BIOS9PathSetting='BIOS9Path='
	BIOS7PathSetting='BIOS7Path='
	FirmwarePathSetting='FirmwarePath='
	DSiBIOS9PathSetting='DSiBIOS9Path='
	DSiBIOS7PathSetting='DSiBIOS7Path='
	DSiFirmwarePathSetting='DSiFirmwarePath='
	DSiNANDPathSetting='DSiNANDPath='
	LastROMFolderSetting='LastROMFolder='

	changeLine "$BIOS9PathSetting" "${BIOS9PathSetting}${biosPath}/bios9.bin" "${melonDS_configFile}"
	changeLine "$BIOS7PathSetting" "${BIOS7PathSetting}${biosPath}/bios7.bin" "${melonDS_configFile}"
	changeLine "$FirmwarePathSetting" "${FirmwarePathSetting}${biosPath}/firmware.bin" "${melonDS_configFile}"
	changeLine "$DSiBIOS9PathSetting" "${DSiBIOS9PathSetting}${biosPath}/dsi_bios9.bin" "${melonDS_configFile}"
	changeLine "$DSiBIOS7PathSetting" "${DSiBIOS7PathSetting}${biosPath}/dsi_bios7.bin" "${melonDS_configFile}"
	changeLine "$DSiFirmwarePathSetting" "${DSiFirmwarePathSetting}${biosPath}/dsi_firmware.bin" "${melonDS_configFile}"
	changeLine "$DSiNANDPathSetting" "${DSiNANDPathSetting}${biosPath}/dsi_nand.bin" "${melonDS_configFile}"
	changeLine "$LastROMFolderSetting" "${LastROMFolderSetting}${romsPath}/nds" "${melonDS_configFile}"

}

#SetupSaves
melonDS_setupSaves(){
	setMSG "Setting $melonDS_emuName Saves Folder"

	mkdir -p "${savesPath}/melonds/saves"
	mkdir -p "${savesPath}/melonds/states"

	SaveFilePathSetting='SaveFilePath='
	SavestatePathSetting='SavestatePath='

	changeLine "$SaveFilePathSetting" "${SaveFilePathSetting}${savesPath}/melonds/saves" "${melonDS_configFile}"
	changeLine "$SavestatePathSetting" "${SavestatePathSetting}${savesPath}/melonds/states" "${melonDS_configFile}"

}


#SetupStorage
melonDS_setupStorage(){
	setMSG "Setting $melonDS_emuName Storage Folder"

	# Leaving this so user can still place database files here if need be
	mkdir -p "$storagePath/melonDS/cheats"

	# Breaks saving cheats in melonDS, commenting out for now
	# CheatFilePathSetting='CheatFilePath='

	# changeLine "$CheatFilePathSetting" "${CheatFilePathSetting}${storagePath}/melonds/cheats" "${melonDS_configFile}"

}


#WipeSettings
melonDS_wipe(){
	setMSG "Wiping $melonDS_emuName config directory. (factory reset)"
	rm -rf "$HOME/.var/app/$melonDS_emuPath"
}


#Uninstall
melonDS_uninstall(){
	setMSG "Uninstalling $melonDS_emuName."
    flatpak uninstall "$melonDS_emuPath" --user -y
}

#setABXYstyle
melonDS_setABXYstyle(){
    	echo "NYI"
}

#Migrate
melonDS_migrate(){
echo "NYI"
}

#WideScreenOn
melonDS_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
melonDS_wideScreenOff(){
echo "NYI"
}

#BezelOn
melonDS_bezelOn(){
echo "NYI"
}

#BezelOff
melonDS_bezelOff(){
decho "NYI"
}

#finalExec - Extra stuff
melonDS_finalize(){
	echo "NYI"
}

melonDS_IsInstalled(){
	isFpInstalled "$melonDS_emuPath"
}

melonDS_resetConfig(){
	melonDS_init &>/dev/null && echo "true" || echo "false"
}

melonDS_addSteamInputProfile(){
	addSteamInputCustomIcons
	#setMSG "Adding $melonDS_emuName Steam Input Profile."
	#rsync -r "$EMUDECKGIT/configs/steam-input/melonds_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

melonDS_setResolution(){
	case $melonDSResolution in
		"720P") WindowWidth=1024; WindowHeight=768;;
		"1080P") WindowWidth=1536; WindowHeight=1152;;
		"1440P") WindowWidth=2048; WindowHeight=1536;;
		"4K") WindowWidth=2816; WindowHeight=2112;;
		*) echo "Error"; exit 1;;
	esac

	RetroArch_setConfigOverride "WindowWidth" $WindowWidth "$melonD_configFile"
	RetroArch_setConfigOverride "WindowHeight" $WindowHeight "$melonD_configFile"
}