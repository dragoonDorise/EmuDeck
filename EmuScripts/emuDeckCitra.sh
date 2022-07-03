#!/bin/bash
#variables
emuName="Citra"
emuType="FlatPak"
emuPath="org.citra_emu.citra"
releaseURL=""

#cleanupOlderThings
cleanupCitra(){
 #na
}

#Install
installCitra(){
	installEmuFP "${emuName}" "${emuPath}"	
	flatpak override "${emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
initCitra(){
	configEmuFP "${emuName}" "${emuPath}" "true"
	setupStorageCitra
	setEmulationFolderCitra
	setupSavesCitra
}

#update
updateCitra(){
	configEmuFP "${emuName}" "${emuPath}"
	setupStorageCitra
	setEmulationFolderCitra
	setupSavesCitra
}

#ConfigurePaths
setEmulationFolderCitra(){
  	configFile="$HOME/.var/app/org.citra_emu.citra/config/citra-emu/qt-config.ini"
    gameDirOpt='Paths\gamedirs\3\path='
    newGameDirOpt='Paths\gamedirs\3\path='"${romsPath}3ds"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
}

#SetupSaves
setupSavesCitra(){
	linkToSaveFolder citra saves "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sdmc"
	linkToSaveFolder citra states "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/states"
}


#SetupStorage
setupStorageCitra(){
    #TBD
}


#WipeSettings
wipeCitra(){
   rm -rf "$HOME/.var/app/$emuPath"
   # prob not cause roms are here
}


#Uninstall
uninstallCitra(){
    flatpack uninstall "$emuPath" -y
}

#setABXYstyle
setABXYstyleCitra(){
    
}

#Migrate
migrateCitra(){
    
}

#WideScreenOn
wideScreenOnCitra(){
#na
}

#WideScreenOff
wideScreenOffCitra(){
#na
}

#BezelOn
bezelOnCitra(){
#na
}

#BezelOff
bezelOffCitra(){
#na
}

#finalExec - Extra stuff
finalizeCitra(){
	#na
}

