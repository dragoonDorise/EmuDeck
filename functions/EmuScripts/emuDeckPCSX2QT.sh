#!/bin/bash
#variables
PCSX2QT_emuName="PCSX2-QT"
PCSX2QT_emuType="AppImage"
PCSX2QT_emuPath="$HOME/Applications/pcsx2-Qt.AppImage"
PCSX2QT_releaseURL=$(getReleaseURLGH "PCSX2/pcsx2" "Qt.AppImage")

#cleanupOlderThings
PCSX2QT_cleanup(){
 echo "NYI"
}

#Install
PCSX2QT_install(){
	echo "Begin PCSX2-QT Install"

	installEmuAI "pcsx2-Qt" "${PCSX2QT_releaseURL}" #pcsx2-Qt.AppImage
}

#ApplyInitialSettings
PCSX2QT_init(){
	setMSG "Initializing $PCSX2QT_emuName settings."	
	configEmuFP  "${PCSX2QT_emuName}" "${PCSX2QT_emuPath}" "true"
	PCSX2QT_setEmulationFolder
	PCSX2QT_setupSaves
	PCSX2QT_addSteamInputProfile
}

#update
PCSX2QT_update(){
	setMSG "Updating $PCSX2QT_emuName settings."
	configEmuFP  "${PCSX2QT_emuName}" "${PCSX2QT_emuPath}"
	PCSX2QT_setEmulationFolder
	PCSX2QT_setupSaves
	PCSX2QT_addSteamInputProfile
}

#ConfigurePaths
PCSX2QT_setEmulationFolder(){
	setMSG "Setting $PCSX2QT_emuName Emulation Folder"
	configFile="$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2QT_ui.ini"
	biosDirOpt='Bios=\/'
	newBiosDirOpt='Bios='"${biosPath}"
	sed -i "/${biosDirOpt}/c\\${newBiosDirOpt}" "$configFile"
}

#SetupSaves
PCSX2QT_setupSaves(){
	linkToSaveFolder pcsx2 saves "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
	linkToSaveFolder pcsx2 states "$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
}


#SetupStorage
PCSX2QT_setupStorage(){
 echo "NYI"
}


#WipeSettings
PCSX2QT_wipe(){
	setMSG "Wiping $PCSX2QT_emuName settings."
   rm -rf "$HOME/.var/app/$PCSX2QT_emuPath"
   # prob not cause roms are here
}


#Uninstall
PCSX2QT_uninstall(){
	setMSG "Uninstalling $PCSX2QT_emuName."
    flatpak uninstall $PCSX2QT_emuPath --user -y
}

#setABXYstyle
PCSX2QT_setABXYstyle(){
    echo "NYI"
}

#Migrate
PCSX2QT_migrate(){
    echo "NYI"
}

#WideScreenOn
PCSX2QT_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
PCSX2QT_wideScreenOff(){
echo "NYI"
}

#BezelOn
PCSX2QT_bezelOn(){
echo "NYI"
}

#BezelOff
PCSX2QT_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
PCSX2QT_finalize(){
	echo "NYI"
}

PCSX2QT_addSteamInputProfile(){
	setMSG "Adding $PCSX2QT_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/PCSX2QT_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}