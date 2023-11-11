#!/bin/bash
#variables
PCSX2_emuName="PCSX2"
PCSX2_emuType="FlatPak"
PCSX2_emuPath="net.pcsx2.PCSX2"
PCSX2_configFile="$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini"

#cleanupOlderThings
PCSX2_cleanup(){
 echo "NYI"
}

#Install
PCSX2_install(){
	installEmuFP "${PCSX2_emuName}" "${PCSX2_emuPath}"
	flatpak override "${PCSX2_emuPath}" --filesystem=host --user
	flatpak override "${PCSX2_emuPath}" --share=network --user
}

#ApplyInitialSettings
PCSX2_init(){
	setMSG "Initializing $PCSX2_emuName settings."
	configEmuFP  "${PCSX2_emuName}" "${PCSX2_emuPath}" "true"
	PCSX2_setEmulationFolder
	PCSX2_setupSaves
	PCSX2_addSteamInputProfile
}

#update
PCSX2_update(){
	setMSG "Updating $PCSX2_emuName settings."
	configEmuFP  "${PCSX2_emuName}" "${PCSX2_emuPath}"
	PCSX2_setEmulationFolder
	PCSX2_setupSaves
	PCSX2_addSteamInputProfile
}

#ConfigurePaths
PCSX2_setEmulationFolder(){
	setMSG "Setting $PCSX2_emuName Emulation Folder"

	biosDirOpt='Bios=/'
	saveStatesDirOpt='Savestates=/'
	memoryCardsDirOpt='MemoryCards=/'

	newBiosDirOpt='Bios='"${biosPath}"
	newsaveStatesDirOpt='Savestates='"${savesPath}/pcsx2/states"
	newmemoryCardsDirOpt='MemoryCards='"${savesPath}/pcsx2/saves"

	changeLine "$biosDirOpt" "$newBiosDirOpt" "$PCSX2_configFile"
	changeLine "$saveStatesDirOpt" "$newsaveStatesDirOpt" "$PCSX2_configFile"
	changeLine "$memoryCardsDirOpt" "$newmemoryCardsDirOpt" "$PCSX2_configFile"
}

#SetupSaves
PCSX2_setupSaves(){
	moveSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
	moveSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
	flatpak override "${PCSX2_emuPath}" --filesystem="${savesPath}/pcsx2":rw --user
}


#SetupStorage
PCSX2_setupStorage(){
 echo "NYI"
}


#WipeSettings
PCSX2_wipe(){
	setMSG "Wiping $PCSX2_emuName settings."
   rm -rf "$HOME/.var/app/$PCSX2_emuPath"
   # prob not cause roms are here
}


#Uninstall
PCSX2_uninstall(){
	setMSG "Uninstalling $PCSX2_emuName."
    flatpak uninstall $PCSX2_emuPath --user -y
}

#setABXYstyle
PCSX2_setABXYstyle(){
    echo "NYI"
}

#Migrate
PCSX2_migrate(){
    echo "NYI"
}

#WideScreenOn
PCSX2_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
PCSX2_wideScreenOff(){
echo "NYI"
}

#BezelOn
PCSX2_bezelOn(){
echo "NYI"
}

#BezelOff
PCSX2_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
PCSX2_finalize(){
	echo "NYI"
}


PCSX2_addSteamInputProfile(){
	echo "NYI"
	#setMSG "Adding $PCSX2_emuName Steam Input Profile."
	#rsync -r "$EMUDECKGIT/configs/steam-input/pcsx2_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

PCSX2_setResolution(){
	case $pcsx2Resolution in
		"720P") multiplier=2;;
		"1080P") multiplier=3;;
		"1440P") multiplier=4;;
		"4K") multiplier=6;;
		*) echo "Error"; exit 1;;
	esac

	RetroArch_setConfigOverride "upscale_multiplier" $multiplier "$PCSX2_configFile"
}