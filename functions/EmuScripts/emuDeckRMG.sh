#!/bin/bash
#variables
RMG_emuName="RosaliesMupenGui"
RMG_emuType="$emuDeckEmuTypeFlatpak"
RMG_emuPath="com.github.Rosalie241.RMG"
RMG_configFile="$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/mupen64plus.cfg"
RMG_glideN64File="$HOME/.var/app/com.github.Rosalie241.RMG/config/RMG/GLideN64.ini"

#cleanupOlderThings
RMG_cleanup(){
 echo "NYI"
}

#Install
RMG_install() {
	setMSG "Installing $RMG_emuName"
	installEmuFP "${RMG_emuName}" "${RMG_emuPath}" "emulator" ""
}

#Fix for autoupdate
Rmg_install(){
	RMG_install
}

#ApplyInitialSettings

RMG_init() {

    setMSG "Initializing $RMG_emuName settings."

	configEmuFP "${RMG_emuName}" "${RMG_emuPath}" "true"
	RMG_setupStorage
	RMG_setEmulationFolder
	RMG_setupSaves
	#SRM_createParsers
	#RMG_addSteamInputProfile
	RMG_flushEmulatorLauncher

}

#update
RMG_update() {
	setMSG "Installing $RMG_emuName"

	configEmuFP "${RMG_emuName}" "${RMG_emuPath}"
	updateEmuFP "${RMG_emuName}" "${RMG_emuPath}" "emulator" ""
	RMG_setupStorage
	RMG_setEmulationFolder
	RMG_setupSaves
	#RMG_addSteamInputProfile
	RMG_flushEmulatorLauncher
}

#ConfigurePaths
RMG_setEmulationFolder(){
	setMSG "Setting $RMG_emuName Emulation Folder"

    # N64 ROMs
	gameDirOpt='Directory = '
    newGameDirOpt="$gameDirOpt""${romsPath}/n64"
	changeLine "$gameDirOpt" "$newGameDirOpt" "$RMG_configFile"

	# N64DD IPL Paths
	AmericanIPL='64DD_AmericanIPL = '
    NewAmericanIPLPath="${AmericanIPL}""${biosPath}/64DD_IPL_US.n64"
	JapaneseIPL='64DD_JapaneseIPL = '
	NewJapaneseIPLPath="${JapaneseIPL}""${biosPath}/64DD_IPL_JP.n64"
	DevelopmentIPL='64DD_DevelopmentIPL = '
	NewDevelopmentIPLPath="${DevelopmentIPL}""${biosPath}/64DD_IPL_DEV.n64"
	changeLine "$AmericanIPL" "$NewAmericanIPLPath" "$RMG_configFile"
	changeLine "$JapaneseIPL" "$NewJapaneseIPLPath" "$RMG_configFile"
	changeLine "$DevelopmentIPL" "$NewDevelopmentIPLPath" "$RMG_configFile"




}

#SetupSaves
RMG_setupSaves(){

	mkdir -p "${savesPath}/RMG/saves"
	mkdir -p "${savesPath}/RMG/states"

	# Saves and Save States
	Saves='SaveSRAMPath = '
	SavesSetting="${Saves}""${savesPath}/RMG/saves"
	SaveStates='SaveStatePath = '
	SaveStatesSetting="${SaveStates}""${savesPath}/RMG/states"

	changeLine "$Saves" "$SavesSetting" "$RMG_configFile"
	changeLine "$SaveStates" "$SaveStatesSetting" "$RMG_configFile"


}


#SetupStorage
RMG_setupStorage(){

	mkdir -p "${storagePath}/RMG/"
	mkdir -p "${storagePath}/RMG/cache"
	mkdir -p "${storagePath}/RMG/HiResTextures"
	mkdir -p "${storagePath}/RMG/screenshots"

    # Configure Settings
    # HiResTextures
    HiResTextureSetting='textureFilter\txHiresEnable='
    enableHiResTextures="${HiResTextureSetting}1"
    changeLine "${HiResTextureSetting}" "${enableHiResTextures}" "$RMG_glideN64File"

    # Configure Paths
	HiResTextures='textureFilter\txPath='
	cache='textureFilter\txCachePath='
	screenshots='ScreenshotPath = '
	UserDataDirectory='UserDataDirectory = '
	UserCacheDirectory='UserCacheDirectory = '

	newHiResTextures='textureFilter\txPath='"${storagePath}/RMG/HiResTextures"
	newcache='textureFilter\txCachePath='"${storagePath}/RMG/cache"
    newscreenshots='ScreenshotPath = '"${storagePath}/RMG/screenshots"
	newUserDataDirectory="${UserDataDirectory}\"$HOME/.var/app/com.github.Rosalie241.RMG/data/RMG\""
	newUserCacheDirectory="${UserCacheDirectory}\"$HOME/.var/app/com.github.Rosalie241.RMG/cache/RMG\""

	changeLine "$HiResTextures" "$newHiResTextures" "$RMG_glideN64File"
	changeLine "$cache" "$newcache" "$RMG_glideN64File"
	changeLine "$screenshots" "$newscreenshots" "$RMG_configFile"
	changeLine "$UserDataDirectory" "$newUserDataDirectory" "$RMG_configFile"
	changeLine "$UserCacheDirectory" "$newUserCacheDirectory" "$RMG_configFile"

}


#WipeSettings
RMG_wipe(){
	rm -rf "$HOME/.var/app/$RMG_emuPath"
}


#Uninstall
RMG_uninstall(){
    uninstallEmuFP "${RMG_emuName}" "${RMG_emuPath}" "emulator" ""
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
	isFpInstalled "$RMG_emuPath"
}

RMG_resetConfig(){
	RMG_init &>/dev/null && echo "true" || echo "false"
}

RMG_addSteamInputProfile(){
	addSteamInputCustomIcons
	#setMSG "Adding $RMG_emuName Steam Input Profile."
	#rsync -r "$EMUDECKGIT/configs/steam-input/rmg_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

#finalExec - Extra stuff
RMG_finalize(){
	echo "NYI"
}

RMG_setResolution(){
	echo "NYI"
}

RMG_setABXYstyle(){
	local header="[Rosalie's Mupen GUI - Input Plugin User Profile \"steamdeck\"]"

	sed -i '/\[Rosalie'"'"'s Mupen GUI - Input Plugin User Profile "steamdeck"\]/,/^\[/ {

		s/B_Name *= *"x"/B_Name = "b"/;
		s/B_Data *= *"2"/B_Data = "1"/;
	}' "$RMG_configFile"

}
RMG_setBAYXstyle(){
	local header="[Rosalie's Mupen GUI - Input Plugin User Profile \"steamdeck\"]"

	sed -i '/\[Rosalie'"'"'s Mupen GUI - Input Plugin User Profile "steamdeck"\]/,/^\[/ {
		s/B_Name *= *"b"/B_Name = "x"/;
		s/B_Data *= *"1"/B_Data = "2"/;
	}' "$RMG_configFile"

}

RMG_flushEmulatorLauncher(){


	flushEmulatorLaunchers "rosaliesmupengui"

}