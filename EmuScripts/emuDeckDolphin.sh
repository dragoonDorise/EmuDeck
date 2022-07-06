#!/bin/bash
#variables
Dolphin_emuName="Dolphin"
Dolphin_emuType="FlatPak"
Dolphin_emuPath="org.DolphinEmu.dolphin-emu"
Dolphin_releaseURL=""

#cleanupOlderThings
Dolphin.cleanup(){
 #na
}

#Install
Dolphin.install(){
	installEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}"	
	flatpak override "${Dolphin_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
Dolphin.init(){
	configEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}" "true"
	Dolphin.setupStorage
	Dolphin.setEmulationFolder
	Dolphin.setupSaves
}

#update
Dolphin.update(){
	configEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}"
	Dolphin.setupStorage
	Dolphin.setEmulationFolder
	Dolphin.setupSaves
}

#ConfigurePaths
Dolphin.setEmulationFolder(){
  	configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini"
    gameDirOpt1='ISOPath0 = '
    newGameDirOpt1='ISOPath0 = '"${romsPath}gc"
    gameDirOpt2='ISOPath1 = '
    newGameDirOpt2='ISOPath1 = '"${romsPath}wii"
    sed -i "/${gameDirOpt1}/c\\${newGameDirOpt1}" "$configFile"
    sed -i "/${gameDirOpt2}/c\\${newGameDirOpt2}" "$configFile"
}

#SetupSaves
Dolphin.setupSaves(){
	linkToSaveFolder dolphin GC "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC"
	linkToSaveFolder dolphin Wii "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii"
	linkToSaveFolder dolphin states "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/states"
}


#SetupStorage
Dolphin.setupStorage(){
    #TBD
}


#WipeSettings
Dolphin.wipe(){
   rm -rf "$HOME/.var/app/$Dolphin_emuPath"
   # prob not cause roms are here
}


#Uninstall
Dolphin.uninstall(){
    flatpack uninstall "$Dolphin_emuPath" -y
}

#setABXYstyle
Dolphin.setABXYstyle(){
    
}

#Migrate
Dolphin.migrate(){
    
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
Dolphin.wideScreenOff(){
    configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    wideScreenHack='wideScreenHack = '
    wideScreenHackSetting='wideScreenHack = False'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 1'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#BezelOn
Dolphin.bezelOn(){
#na
}

#BezelOff
Dolphin.bezelOff(){
#na
}

#finalExec - Extra stuff
Dolphin.finalize(){
	#na
}

