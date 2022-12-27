#!/bin/bash
#variables
RMG_emuName="RMG"
RMG_emuType="FlatPak"
RMG_emuPath="com.github.Rosalie241.RMG"
RMG_releaseURL=""
RMG_configFile="$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/mupen64plus.cfg"
RMG_gliden64File="$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/GLideN64.ini"

#cleanupOlderThings
RMG_cleanup(){
 echo "NYI"
}

#Install
RMG_install() {
	setMSG "Installing $RMG_emuName"	

	installEmuFP "${RMG_emuName}" "${RMG_emuPath}"
	flatpak override "${RMG_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings

RMG_init() {

    setMSG "Initializing $RMG_emuName settings."

	configEmuFP "${RMG_emuName}" "${RMG_emuPath}" "true"
	RMG_setupStorage
	RMG_setEmulationFolder
	RMG_setupSaves
	RMG_addSteamInputProfile

}

#update
RMG_update() {
	setMSG "Installing $RMG_emuName"		

	configEmuFP "${RMG_emuName}" "${RMG_emuPath}"
	RMG_setupStorage
	RMG_setEmulationFolder
	RMG_setupSaves
	RMG_addSteamInputProfile

}

#ConfigurePaths
RMG_setEmulationFolder(){
	setMSG "Setting $RMG_emuName Emulation Folder"

    # N64 ROMs
	gameDirOpt='Directory='
    newGameDirOpt="$gameDirOpt""${romsPath}/n64"
	changeLine "$gameDirOpt" "$newGameDirOpt" "$RMG_configFile"

	# N64DD ROMs, pending RMG update
    
	# N64DD ROMs Path, pending RMG update
	
	# N64DD IPL Paths
	AmericanIPL= = '64DD_AmericanIPL = '
    NewAmericanIPLPath="${AmericanIPL}""${biosPath}/64DD_IPL_US.n64"
	JapaneseIPL= = '64DD_JapaneseIPL = '
	NewJapaneseIPLPath="${JapaneseIPL}""${biosPath}/64DD_IPL_J.n64"
	DevelopmentIPL='64DD_DevelopmentIPL = '
	NewDevelopmentIPLPath="${DevelopmentIPL}""${biosPath}/64DD_IPL_DEV.n64"
    
	# Saves and Save States
	Saves='SaveSRAMPath = '
	SavesSetting="${Saves}""${savesPath}/RMG/saves"
	SaveStates='SaveStatePath = '
	SaveStatesSetting="${SaveStates}""${savesPath}/RMG/states"

	changeLine "$Saves" "$SavesSetting" "$RMG_configFile"
	changeLine "$SaveStates" "$SaveStatesSetting" "$RMG_configFile"



 

}

#SetupSaves
RMG_setupSaves(){

	moveSaveFolder RMG saves "$HOME/.var/app/com.github.Rosalie241.RMG/data/mupen64plus/Game"
	moveSaveFolder RMG states "$HOME/.var/app/com.github.Rosalie241.RMG/data/mupen64plus/State"
}


#SetupStorage
RMG_setupStorage(){
	
	RMG_gliden64File="$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/GLideN64.ini"
	mkdir -p "${storagePath}/RMG/"

    # Configure Settings
    HiResTextureSetting='textureFilter\txHiresEnable= '
    enableHiResTextures="${HiResTextureSetting}'1'"
    changeLine "${HiResTextureSetting}" "${enableHiResTextures}" "$RMG_gliden64File"

    # Configure Paths
	HiResTextures='textureFilter\txPath= '
	cache='textureFilter\txCachePath= '

	newHiResTextures='textureFilter\txPath= '"${storagePath}/RMG/HiResTextures"
	newcache='Snapshots= '"${storagePath}/RMG/cache"

	changeLine "$HiResTextures" "$newHiResTextures" "$RMG_gliden64File"
	changeLine "$cache" "$newcache" "$RMG_gliden64File"

}


#WipeSettings
RMG_wipe(){
	rm -rf "$HOME/.var/app/$RMG_emuPath"
}


#Uninstall
RMG_uninstall(){
    flatpak uninstall "$RMG_emuPath" --user -y
}

#setABXYstyle
RMG_setABXYstyle(){
	echo "NYI"    
}

#Migrate
RMG_migrate(){
	echo "NYI"    
}

#WideScreenOn
RMG_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
RMG_wideScreenOff(){
	echo "NYI"
}

#BezelOn
RMG_bezelOn(){
echo "NYI"
}

#BezelOff
RMG_bezelOff(){
echo "NYI"
}

RMG_IsInstalled(){
	if [ "$(flatpak --columns=app list | grep "$RMG_emuPath")" == "$RMG_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

RMG_resetConfig(){
	RMG_init &>/dev/null && echo "true" || echo "false"
}

RMG_addSteamInputProfile(){
	setMSG "Adding $RMG_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/rmg_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

#finalExec - Extra stuff
RMG_finalize(){
	echo "NYI"
}

