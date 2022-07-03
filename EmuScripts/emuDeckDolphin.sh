#!/bin/bash
#variables
emuName="Dolphin"
emuType="FlatPak"
emuPath="org.DolphinEmu.dolphin-emu"
releaseURL=""

#cleanupOlderThings
cleanupDolphin(){
 #na
}

#Install
installDolphin(){
	installEmuFP "${emuName}" "${emuPath}"	
	flatpak override "${emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
initDolphin(){
	configEmuFP "${emuName}" "${emuPath}" "true"
	setupStorageDolphin
	setEmulationFolderDolphin
	setupSavesDolphin
}

#update
updateDolphin(){
	configEmuFP "${emuName}" "${emuPath}"
	setupStorageDolphin
	setEmulationFolderDolphin
	setupSavesDolphin
}

#ConfigurePaths
setEmulationFolderDolphin(){
  	configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini"
    gameDirOpt1='ISOPath0 = '
    newGameDirOpt1='ISOPath0 = '"${romsPath}gc"
    gameDirOpt2='ISOPath1 = '
    newGameDirOpt2='ISOPath1 = '"${romsPath}wii"
    sed -i "/${gameDirOpt1}/c\\${newGameDirOpt1}" "$configFile"
    sed -i "/${gameDirOpt2}/c\\${newGameDirOpt2}" "$configFile"
}

#SetupSaves
setupSavesDolphin(){
	linkToSaveFolder dolphin GC "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC"
	linkToSaveFolder dolphin Wii "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii"
	linkToSaveFolder dolphin states "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/states"
}


#SetupStorage
setupStorageDolphin(){
    #TBD
}


#WipeSettings
wipeDolphin(){
   rm -rf "$HOME/.var/app/$emuPath"
   # prob not cause roms are here
}


#Uninstall
uninstallDolphin(){
    flatpack uninstall "$emuPath" -y
}

#setABXYstyle
setABXYstyleDolphin(){
    
}

#Migrate
migrateDolphin(){
    
}

#WideScreenOn
wideScreenOnDolphin(){
    configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    wideScreenHack='wideScreenHack = '
    wideScreenHackSetting='wideScreenHack = True'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 0'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#WideScreenOff
wideScreenOffDolphin(){
    configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    wideScreenHack='wideScreenHack = '
    wideScreenHackSetting='wideScreenHack = False'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 1'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#BezelOn
bezelOnDolphin(){
#na
}

#BezelOff
bezelOffDolphin(){
#na
}

#finalExec - Extra stuff
finalizeDolphin(){
	#na
}

