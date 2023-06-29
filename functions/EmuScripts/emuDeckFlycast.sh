#!/bin/bash

#variables
Flycast_emuName="Flycast"
Flycast_emuType="FlatPak"
Flycast_emuPath="org.flycast.Flycast"
Flycast_configFile="$HOME/.var/app/org.flycast.Flycast/config/flycast/emu.cfg"

#cleanupOlderThings
Flycast_cleanup(){
 echo "NYI"
}

#Install
Flycast_install(){
	setMSG "Installing $Flycast_emuName"		

	installEmuFP "${Flycast_emuName}" "${Flycast_emuPath}"	
	flatpak override "${Flycast_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
Flycast_init(){
	setMSG "Initializing $Flycast_emuName settings."
	configEmuFP "${Flycast_emuName}" "${Flycast_emuPath}" "true"
	Flycast_setupStorage
	Flycast_setEmulationFolder
	Flycast_setupSaves
	Flycast_addSteamInputProfile
}

#update
Flycast_update(){
	setMSG "Updating $Flycast_emuName settings."
	configEmuFP "${Flycast_emuName}" "${Flycast_emuPath}"
	Flycast_setupStorage
	Flycast_setEmulationFolder
	Flycast_setupSaves
	Flycast_addSteamInputProfile
}

#ConfigurePaths
Flycast_setEmulationFolder(){
	setMSG "Setting $Flycast_emuName Emulation Folder"

	ContentPathSetting='Dreamcast.ContentPath = '
	changeLine "$ContentPathSetting" "${ContentPathSetting}${romsPath}/dreamcast" "${Flycast_configFile}"

	#Setup symlink for bios
	mkdir -p "${biosPath}/flycast/"
	mkdir -p "$HOME/.var/app/org.flycast.Flycast/data/flycast/"
    ln -sn "$HOME/.var/app/org.flycast.Flycast/data/flycast/" "${biosPath}/flycast/bios"
}

#SetupSaves
Flycast_setupSaves(){
    linkToSaveFolder flycast saves "$HOME/.var/app/org.flycast.Flycast/data/flycast/"
	linkToSaveFolder flycast states "$HOME/.var/app/org.flycast.Flycast/config/data/flycast/"
}


#SetupStorage
Flycast_setupStorage(){
	echo "NYI"
}


#WipeSettings
Flycast_wipe(){
	setMSG "Wiping $Flycast_emuName settings folder."	
   	rm -rf "$HOME/.var/app/$Flycast_emuPath"
}


#Uninstall
Flycast_uninstall(){
	setMSG "Uninstalling ${Flycast_emuName}."	
    flatpak uninstall "$Flycast_emuPath" --user -y
}

#setABXYstyle
Flycast_setABXYstyle(){
    	echo "NYI"
}

#Migrate
Flycast_migrate(){
	echo "NYI"
}

#WideScreenOn
Flycast_wideScreenOn(){
	setMSG "${Flycast_emuName}: Widescreen On"
    echo ""
    wideScreenHack='rend.WidescreenGameHacks = '
    wideScreenHackSetting='rend.WidescreenGameHacks = yes'
    aspectRatio='rend.WideScreen = '
    aspectRatioSetting='rend.WideScreen = yes'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$Flycast_configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$Flycast_configFile"
}

#WideScreenOff
Flycast_wideScreenOff(){
	setMSG "${Flycast_emuName}: Widescreen Off"
    echo ""
    wideScreenHack='rend.WidescreenGameHacks = '
    wideScreenHackSetting='rend.WidescreenGameHacks = no'
    aspectRatio='rend.WideScreen = '
    aspectRatioSetting='rend.WideScreen = no'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$Flycast_configFile"
	sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$Flycast_configFile"
}

#BezelOn
Flycast_bezelOn(){
echo "NYI"
}

#BezelOff
Flycast_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Flycast_finalize(){
	echo "NYI"
}

Flycast_IsInstalled(){
	if [ "$(flatpak --columns=app list | grep "$Flycast_emuPath")" == "$Flycast_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Flycast_resetConfig(){
	Flycast_init &>/dev/null && echo "true" || echo "false"
}

Flycast_addSteamInputProfile(){
	echo "NYI"
	# setMSG "Adding $Flycast_emuName Steam Input Profile."
	# rsync -r "$EMUDECKGIT/configs/steam-input/Flycast_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}