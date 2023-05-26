#!/bin/bash
#variables
ares_emuName="ares"
ares_emuType="FlatPak"
ares_emuPath="dev.ares.ares"
ares_configFile="$HOME/.var/app/dev.ares.ares/data/ares/settings.bml"

#cleanupOlderThings
ares_cleanup(){
 echo "NYI"
}

#Install
ares_install() {
	setMSG "Installing $ares_emuName"	

	installEmuFP "${ares_emuName}" "${ares_emuPath}"
	flatpak override "${ares_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings

ares_init() {

    setMSG "Initializing $ares_emuName settings."

	configEmuFP "${ares_emuName}" "${ares_emuPath}" "true"
	ares_setupStorage
	ares_setEmulationFolder
	ares_setupSaves
	ares_addSteamInputProfile

}

#update
ares_update() {
	setMSG "Installing $ares_emuName"		

	configEmuFP "${ares_emuName}" "${ares_emuPath}"
	ares_setupStorage
	ares_setEmulationFolder
	ares_setupSaves
	ares_addSteamInputProfile

}

#ConfigurePaths
ares_setEmulationFolder(){
	setMSG "Setting $ares_emuName Emulation Folder"

	iniFieldUpdate "$ares_configFile" "Atari2600" "Path" "${romsPath}/atari2600"
	iniFieldUpdate "$ares_configFile" "SuperFamicom" "Path" "${romsPath}/snes"
	iniFieldUpdate "$ares_configFile" "PCEngine" "Path" "${romsPath}/pcengine"

 

}

#SetupSaves
ares_setupSaves(){

	# Saves and Save States
	Saves='SaveSRAMPath = '
	SavesSetting="${Saves}""${savesPath}/ares/saves"
	SaveStates='SaveStatePath = '
	SaveStatesSetting="${SaveStates}""${savesPath}/ares/states"

	changeLine "$Saves" "$SavesSetting" "$ares_configFile"
	changeLine "$SaveStates" "$SaveStatesSetting" "$ares_configFile"


}


#SetupStorage
ares_setupStorage(){
	
	mkdir -p "${storagePath}/ares/"
	mkdir -p "${storagePath}/ares/cache"
	mkdir -p "${storagePath}/ares/HiResTextures"
	mkdir -p "${storagePath}/ares/screenshots"

    # Configure Settings
    # HiResTextures
    HiResTextureSetting='textureFilter\txHiresEnable='
    enableHiResTextures="${HiResTextureSetting}1"
    changeLine "${HiResTextureSetting}" "${enableHiResTextures}" "$ares_glideN64File"

    # Configure Paths
	HiResTextures='textureFilter\txPath='
	cache='textureFilter\txCachePath='
	screenshots='ScreenshotPath = '
	UserDataDirectory='UserDataDirectory = '
	UserCacheDirectory='UserCacheDirectory = ' 

	newHiResTextures='textureFilter\txPath='"${storagePath}/ares/HiResTextures"
	newcache='textureFilter\txCachePath='"${storagePath}/ares/cache"
    newscreenshots='ScreenshotPath = '"${storagePath}/ares/screenshots"
	newUserDataDirectory="${UserDataDirectory}\"$HOME/.var/app/com.github.Rosalie241.ares/data/ares\""
	newUserCacheDirectory="${UserCacheDirectory}\"$HOME/.var/app/com.github.Rosalie241.ares/cache/ares\""
	
	changeLine "$HiResTextures" "$newHiResTextures" "$ares_glideN64File"
	changeLine "$cache" "$newcache" "$ares_glideN64File"
	changeLine "$screenshots" "$newscreenshots" "$ares_configFile"
	changeLine "$UserDataDirectory" "$newUserDataDirectory" "$ares_configFile"
	changeLine "$UserCacheDirectory" "$newUserCacheDirectory" "$ares_configFile"

}


#WipeSettings
ares_wipe(){
	rm -rf "$HOME/.var/app/$ares_emuPath"
}


#Uninstall
ares_uninstall(){
    flatpak uninstall "$ares_emuPath" --user -y
}

#setABXYstyle
ares_setABXYstyle(){
	echo "NYI"    
}

#Migrate
ares_migrate(){
	echo "NYI"    
}

#WideScreenOn
ares_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
ares_wideScreenOff(){
	echo "NYI"
}

#BezelOn
ares_bezelOn(){
echo "NYI"
}

#BezelOff
ares_bezelOff(){
echo "NYI"
}

ares_IsInstalled(){
	isFpInstalled "$ares_emuPath"
}

ares_resetConfig(){
	ares_init &>/dev/null && echo "true" || echo "false"
}

ares_addSteamInputProfile(){
	addSteamInputCustomIcons
	setMSG "Adding $ares_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/rmg_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

#finalExec - Extra stuff
ares_finalize(){
	echo "NYI"
}

