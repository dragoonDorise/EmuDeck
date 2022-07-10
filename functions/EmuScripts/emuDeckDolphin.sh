#!/bin/bash
#variables
Dolphin_emuName="Dolphin"
Dolphin_emuType="FlatPak"
Dolphin_emuPath="org.DolphinEmu.dolphin-emu"
Dolphin_releaseURL=""

#cleanupOlderThings
Dolphin.cleanup(){
 echo "NYI"
}

#Install
Dolphin.install(){
    echo "Dolphin: Install"
    echo ""
	installEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}"	
	flatpak override "${Dolphin_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
Dolphin.init(){
    echo "Dolphin: Apply initial config"
    echo ""
	configEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}" "true"
	Dolphin.setupStorage
	Dolphin.setEmulationFolder
	Dolphin.setupSaves
}

#update
Dolphin.update(){
    echo "Dolphin: Apply configuration Update"
    echo ""
	configEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}"
	Dolphin.setupStorage
	Dolphin.setEmulationFolder
	Dolphin.setupSaves
}

#ConfigurePaths
Dolphin.setEmulationFolder(){
    echo "Dolphin: Configure Emulation folder"
    echo ""
  	configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini"
    gameDirOpt1='ISOPath0 = '
    gameDirOpt1Setting='ISOPath0 = '"${romsPath}gc"
    gameDirOpt2='ISOPath1 = '
    gameDirOpt2Setting='ISOPath1 = '"${romsPath}wii"
    sed -i "/${gameDirOpt1}/c\\${gameDirOpt1Setting}" "$configFile"
    sed -i "/${gameDirOpt2}/c\\${gameDirOpt2Setting}" "$configFile"
}

#SetupSaves
Dolphin.setupSaves(){
    echo "Dolphin: setup Saves folder"
    echo ""
	linkToSaveFolder dolphin GC "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC"
	linkToSaveFolder dolphin Wii "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii"
	linkToSaveFolder dolphin states "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/states"
}


#SetupStorage
Dolphin.setupStorage(){
    echo "NYI"#TBD
}


#WipeSettings
Dolphin.wipe(){
   rm -rf "$HOME/.var/app/$Dolphin_emuPath"
   # prob not cause roms are here
}


#Uninstall
Dolphin.uninstall(){
    flatpak uninstall "$Dolphin_emuPath" --user -y
}

#setABXYstyle
Dolphin.setABXYstyle(){
   	echo "NYI" 
}

#Migrate
Dolphin.migrate(){
    	echo "NYI"
}

#WideScreenOn
Dolphin.wideScreenOn(){
    echo "Dolphin: Widescreen On"
    echo ""
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
    echo "Dolphin: Widescreen Off"
    echo ""
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
echo "NYI"
}

#BezelOff
Dolphin.bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Dolphin.finalize(){
	echo "NYI"
}

