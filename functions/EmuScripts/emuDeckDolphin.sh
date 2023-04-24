#!/bin/bash
#variables
Dolphin_emuName="Dolphin"
Dolphin_emuType="FlatPak"
Dolphin_emuPath="org.DolphinEmu.dolphin-emu"
Dolphin_releaseURL=""

#cleanupOlderThings
Dolphin_cleanup(){
    #backup old Dolphin input profiles, if the user wants to keep them
    #wii
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/SD-GyroAccelTouch.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/SD-GyroAccelTouch.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/SD-PkmBtlRev.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/SD-PkmBtlRev.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/SD-Touch+Joy.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/SD-Touch+Joy.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/SD-xbox.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/SD-xbox.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/stdxbox.ini"  "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/stdxbox.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/steamxb2.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/steamxb2.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/steamxb3.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/steamxb3.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/steamxb4.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/steamxb4.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/stock with mouse.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/stock with mouse.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/stock.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/stock.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/wiigalaxy.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/Wiimote/wiigalaxy.ini.old"
    #GC
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/base.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/base.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/steam1.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/steam1.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/steam2.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/steam2.ini.old" 
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/steam3.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/steam3.ini.old"
    mv "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/steam4.ini" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Profiles/GCPad/steam4.ini.old"
    echo "Old EmuDeck profiles, if they existed backed up to .bak"
}

#Install
Dolphin_install(){
    setMSG "${Dolphin_emuName}: Install"
    echo ""
	installEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}"	
	flatpak override "${Dolphin_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
Dolphin_init(){
    setMSG "${Dolphin_emuName}: Apply initial config"
    echo ""
	configEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}" "true"
	Dolphin_setupStorage
	Dolphin_setEmulationFolder
	Dolphin_setupSaves
  Dolphin_cleanup
  #Dolphin_DynamicInputTextures
}

#update
Dolphin_update(){
    setMSG "${Dolphin_emuName}: Apply configuration Update"
    echo ""
	configEmuFP "${Dolphin_emuName}" "${Dolphin_emuPath}"
	Dolphin_setupStorage
	Dolphin_setEmulationFolder
	Dolphin_setupSaves
    Dolphin_cleanup
}

#ConfigurePaths
Dolphin_setEmulationFolder(){
    setMSG "${Dolphin_emuName}: Configure Emulation folder"
    echo ""
  	local configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini"
    gameDirOpt1='ISOPath0 = '
    gameDirOpt1Setting='ISOPath0 = '"${romsPath}/gc"
    gameDirOpt2='ISOPath1 = '
    gameDirOpt2Setting='ISOPath1 = '"${romsPath}/wii"
    sed -i "/${gameDirOpt1}/c\\${gameDirOpt1Setting}" "$configFile"
    sed -i "/${gameDirOpt2}/c\\${gameDirOpt2Setting}" "$configFile"
}

#SetupSaves
Dolphin_setupSaves(){
    setMSG "${Dolphin_emuName}: setup Saves folder"
    echo ""
    unlink "$savesPath/dolphin/states"
	linkToSaveFolder dolphin GC "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC"
	linkToSaveFolder dolphin Wii "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii"
	linkToSaveFolder dolphin StateSaves "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves"
}


#SetupStorage
Dolphin_setupStorage(){
    echo "NYI"#TBD
}


#WipeSettings
Dolphin_wipe(){
   rm -rf "$HOME/.var/app/$Dolphin_emuPath"
   # prob not cause roms are here
}


#Uninstall
Dolphin_uninstall(){
    flatpak uninstall "$Dolphin_emuPath" --user -y
}

#setABXYstyle
Dolphin_setABXYstyle(){
   	echo "NYI" 
}

#Migrate
Dolphin_migrate(){
   	echo "NYI" 
}

#WideScreenOn
Dolphin_wideScreenOn(){
    setMSG "${Dolphin_emuName}: Widescreen On"
    echo ""
    configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    wideScreenHack='wideScreenHack = '
    wideScreenHackSetting='wideScreenHack = True'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 1'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#WideScreenOff
Dolphin_wideScreenOff(){
    setMSG "${Dolphin_emuName}: Widescreen Off"
    echo ""
    local configFile="$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    wideScreenHack='wideScreenHack = '
    wideScreenHackSetting='wideScreenHack = False'
    aspectRatio='AspectRatio = '
    aspectRatioSetting='AspectRatio = 0'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#BezelOn
Dolphin_bezelOn(){
echo "NYI"
}

#BezelOff
Dolphin_bezelOff(){
echo "NYI"
}

Dolphin_IsInstalled(){
	isFpInstalled "$Dolphin_emuPath"
}

Dolphin_resetConfig(){
	Dolphin_init &>/dev/null && echo "true" || echo "false"
}
#finalExec - Extra stuff
Dolphin_finalize(){
	echo "NYI"
}


Dolphin_DynamicInputTextures(){
  local DIT_releaseURL="$(getLatestReleaseURLGH "Venomalia/UniversalDynamicInput" "7z")"
  
  if [[ ! -e "$storagePath/dolphin/Load" ]]; then
    mkdir -p "$storagePath/dolphin/Load"
    ln -s "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Load/" "$storagePath/dolphin/Load/"
  fi
  
  if safeDownload "UniversalDynamicInput" "$DIT_releaseURL" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Load/DynamicInputTextures.7z" "false"; then      
    7z "$storagePath/dolphin/Load/DynamicInputTextures.7z" -o"$storagePath/dolphin/Load/" && rm -rf "$storagePath/Dolphin/Load/DynamicInputTextures.7z"    
  else
    return 1
  fi
}