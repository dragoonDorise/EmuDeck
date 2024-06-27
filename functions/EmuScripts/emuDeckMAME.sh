#!/bin/bash
#variables
MAME_emuName="MAME"
MAME_emuType="$emuDeckEmuTypeFlatpak"
MAME_emuPath="org.mamedev.MAME"
MAME_releaseURL=""
MAME_configFile="$HOME/.mame/mame.ini"

#cleanupOlderThings
MAME_cleanup(){
 echo "NYI"
}

#Install
MAME_install(){
	installEmuFP "${MAME_emuName}" "${MAME_emuPath}" "emulator" ""
}

#Fix for autoupdate
Mame_install(){
	MAME_install
}

#ApplyInitialSettings
MAME_init(){
	configEmuAI "${MAME_emuName}" "mame" "$HOME/.mame" "${EMUDECKGIT}/configs/mame" "true"
	MAME_setupStorage
	MAME_setEmulationFolder
	MAME_setupSaves
	#SRM_createParsers
	MAME_flushEmulatorLauncher
	MAME_addSteamInputProfile

	# If writeconfig is set to 1 in mame.ini, these files get created. Back up on reset so users can get the default/EmuDeck configured mame.ini file in ~/.mame
	# writeconfig is disabled by default. Was enabled by default for a short time. 
	if [ -f "$storagePath/mame/ini/mame.ini" ]; then
		mv "$storagePath/mame/ini/mame.ini" "$storagePath/mame/ini/mame.ini.bak"
	fi
	if [ -f "$storagePath/mame/ini/ui.ini" ]; then
		mv "$storagePath/mame/ini/ui.ini" "$storagePath/mame/ini/ui.ini.bak"
	fi
	if [ -f "$HOME/.mame/ini/mame.ini" ]; then
		mv "$HOME/.mame/ini/mame.ini" "$HOME/.mame/ini/mame.ini.bak"
	fi
	if [ -f "$HOME/.mame/ini/ui.ini" ]; then
		mv "$HOME/.mame/ini/ui.ini" "$HOME/.mame/ini/ui.ini.bak"
	fi

}

#update
MAME_update(){
	configEmuAI "${MAME_emuName}" "mame" "$HOME/.mame" "${EMUDECKGIT}/configs/mame"
	updateEmuFP "${MAME_emuName}" "${MAME_emuPath}" "emulator" ""
	MAME_setupStorage
	MAME_setEmulationFolder
	MAME_setupSaves
	MAME_flushEmulatorLauncher
	MAME_addSteamInputProfile
}

#ConfigurePaths
MAME_setEmulationFolder(){

    gameDirOpt='rompath                   '
    newGameDirOpt="$gameDirOpt""${romsPath}/arcade;${biosPath};${biosPath}/mame"
	changeLine "$gameDirOpt" "$newGameDirOpt" "$MAME_configFile"

	samplepathOpt='samplepath                '
	newSamplepathOpt="$samplepathOpt""$storagePath/mame/samples;"'$HOME/.mame/samples;/app/share/mame/samples'
	changeLine "$samplepathOpt" "$newSamplepathOpt" "$MAME_configFile"

	artpathOpt='artpath                   '
	newArtpathOpt="$artpathOpt""$storagePath/mame/artwork;"'$HOME/.mame/artwork;/app/share/mame/artwork'
	changeLine "$artpathOpt" "$newArtpathOpt" "$MAME_configFile"

	ctrlrpathOpt='ctrlrpath                 '
	newctrlrpathOpt="$ctrlrpathOpt""$storagePath/mame/ctrlr;"'$HOME/.mame/ctrlr;/app/share/mame/ctrlr'
	changeLine "$ctrlrpathOpt" "$newctrlrpathOpt" "$MAME_configFile"

	inipathOpt='inipath                   '
	newinipathOpt="$inipathOpt""$storagePath/mame/ini;"'$HOME/.mame/ini;$HOME/.mame;/app/share/mame/ini'
	changeLine "$inipathOpt" "$newinipathOpt" "$MAME_configFile"

	cheatpathOpt='cheatpath                 '
	newcheatpathOpt="$cheatpathOpt""$storagePath/mame/cheat;"'$HOME/.mame/cheat;/app/share/mame/cheat'
	changeLine "$cheatpathOpt" "$newcheatpathOpt" "$MAME_configFile"

	pluginspathOpt='pluginspath               '
	newpluginspathOpt="$pluginspathOpt""$storagePath/mame/plugins;"'$HOME/.mame/plugins;/app/share/mame/plugins'
	changeLine "$pluginspathOpt" "$newpluginspathOpt" "$MAME_configFile"

}

#SetupSaves
MAME_setupSaves(){

	nvram_directoryOpt='nvram_directory           '
	newnvram_directoryOpt="$nvram_directoryOpt""$savesPath/mame/saves"
	changeLine "$nvram_directoryOpt" "$newnvram_directoryOpt" "$MAME_configFile"

	state_directoryOpt='state_directory           '
	newstate_directoryOpt="$state_directoryOpt""$savesPath/mame/states"
	changeLine "$state_directoryOpt" "$newstate_directoryOpt" "$MAME_configFile"

	moveSaveFolder MAME saves "$HOME/.mame/nvram"
	moveSaveFolder MAME states "$HOME/.mame/sta"
}


#SetupStorage
MAME_setupStorage(){
	mkdir -p "$storagePath/mame/samples"
	mkdir -p "$storagePath/mame/artwork"
	mkdir -p "$storagePath/mame/ctrlr"
	mkdir -p "$storagePath/mame/ini"
	mkdir -p "$storagePath/mame/cheat"
	mkdir -p "$storagePath/mame/plugins"

	mkdir -p "$HOME/.mame/samples"
	mkdir -p "$HOME/.mame/artwork"
	mkdir -p "$HOME/.mame/ctrlr"
	mkdir -p "$HOME/.mame/ini"
	mkdir -p "$HOME/.mame/cheat"
	mkdir -p "$HOME/.mame/plugins"

}


#WipeSettings
MAME_wipe(){
   rm -rf "$HOME/.mame"
}


#Uninstall
MAME_uninstall(){
    uninstallEmuFP "${MAME_emuName}" "${MAME_emuPath}" "emulator" ""
}

#setABXYstyle
MAME_setABXYstyle(){
	echo "NYI"
}

#Migrate
MAME_migrate(){
	echo "NYI"
}

#WideScreenOn
MAME_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
MAME_wideScreenOff(){
	echo "NYI"
}

#BezelOn
MAME_bezelOn(){
echo "NYI"
}

#BezelOff
MAME_bezelOff(){
echo "NYI"
}

MAME_IsInstalled(){
	isFpInstalled "$MAME_emuPath"
}

MAME_resetConfig(){
	MAME_init &>/dev/null && echo "true" || echo "false"
}

#finalExec - Extra stuff
MAME_finalize(){
	echo "NYI"
}

MAME_flushEmulatorLauncher(){


	flushEmulatorLaunchers "mame"

}

MAME_addSteamInputProfile(){
	setMSG "Adding $MAME_emuName Steam Input Profile."
	rsync -r --exclude='*/' "$EMUDECKGIT/configs/steam-input/emudeck_steam_deck_light_gun_controls.vdf" "$HOME/.steam/steam/controller_base/templates/emudeck_steam_deck_light_gun_controls.vdf"
}