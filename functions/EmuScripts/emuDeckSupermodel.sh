#!/bin/bash
#variables
Supermodel_emuName="Supermodel"
Supermodel_emuType="$emuDeckEmuTypeFlatpak"
Supermodel_emuPath="com.supermodel3.Supermodel"
Supermodel_releaseURL=""
Supermodel_configFile="$HOME/.supermodel/Config/Supermodel.ini"
Supermodel_gamesList="https://raw.githubusercontent.com/trzy/Supermodel/master/Config/Games.xml"

#cleanupOlderThings
Supermodel_cleanup(){
 echo "NYI"
}

#Install
Supermodel_install(){
	setMSG "Installing $Supermodel_emuName"
	installEmuFP "${Supermodel_emuName}" "${Supermodel_emuPath}" "emulator" ""
}

#ApplyInitialSettings
Supermodel_init(){
	# Flatpak does not install to flatpak directory
	mkdir -p $HOME/.supermodel/Analysis $HOME/.supermodel/Log
	rsync -avhp --mkpath "$EMUDECKGIT/configs/supermodel/Config/Supermodel.ini" "$HOME/.supermodel/Config/Supermodel.ini" --backup --suffix=.bak
	rsync -avhp --mkpath "$EMUDECKGIT/configs/supermodel/." "$HOME/.supermodel/." --backup --suffix=.bak
	# Download updated gamelist from source
	if [ -e "$HOME/.supermodel/Config/Games.xml" ]; then
		rm -rf "$HOME/.supermodel/Config/Games.xml"
	fi
	wget "$Supermodel_gamesList" -P "$HOME/.supermodel/Config/"
	Supermodel_setupStorage
	Supermodel_setEmulationFolder
	Supermodel_setupSaves
	#SRM_createParsers
	Supermodel_flushEmulatorLauncher
	Supermodel_addSteamInputProfile
}

#update
Supermodel_update(){
	# Flatpak does not install to flatpak directory
	mkdir -p $HOME/.supermodel/Analysis $HOME/.supermodel/Log
	rsync -avhp --mkpath "$EMUDECKGIT/configs/supermodel" "$HOME/.supermodel/" --ignore-existing
	# Download updated gamelist from source
	if [ -e "$HOME/.supermodel/Config/Games.xml" ]; then
		rm -rf "$HOME/.supermodel/Config/Games.xml"
	fi
	wget "$Supermodel_gamesList" -P "$HOME/.supermodel/Config/"
	updateEmuFP "${Supermodel_emuName}" "${Supermodel_emuPath}" "emulator" ""
	Supermodel_setupStorage
	Supermodel_setEmulationFolder
	Supermodel_setupSaves
	Supermodel_flushEmulatorLauncher
	Supermodel_addSteamInputProfile
}

#ConfigurePaths
Supermodel_setEmulationFolder(){
	echo "NYI"
}

#SetupSaves
Supermodel_setupSaves(){
	echo "NYI"
}


#SetupStorage
Supermodel_setupStorage(){
	echo "NYI"
}


#WipeSettings
Supermodel_wipe(){
	echo "NYI"
}


#Uninstall
Supermodel_uninstall(){
    uninstallEmuFP "${Supermodel_emuName}" "${Supermodel_emuPath}" "emulator" ""
	rm -rf "$HOME/.supermodel"
}

#setABXYstyle
Supermodel_setABXYstyle(){
	echo "NYI"
}

#Migrate
Supermodel_migrate(){
	echo "NYI"
}

#WideScreenOn
Supermodel_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Supermodel_wideScreenOff(){
	echo "NYI"
}

#BezelOn
Supermodel_bezelOn(){
echo "NYI"
}

#BezelOff
Supermodel_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Supermodel_finalize(){
	echo "NYI"
}

Supermodel_IsInstalled(){
	isFpInstalled "$Supermodel_emuPath"
}

Supermodel_resetConfig(){
	Supermodel_init &>/dev/null && echo "true" || echo "false"
}

Supermodel_flushEmulatorLauncher(){


	flushEmulatorLaunchers "supermodel"

}

Supermodel_addSteamInputProfile(){
	setMSG "Adding $Supermodel_emuName Steam Input Profile."
	rsync -r --exclude='*/' "$EMUDECKGIT/configs/steam-input/emudeck_steam_deck_light_gun_controls.vdf" "$HOME/.steam/steam/controller_base/templates/emudeck_steam_deck_light_gun_controls.vdf"
}
