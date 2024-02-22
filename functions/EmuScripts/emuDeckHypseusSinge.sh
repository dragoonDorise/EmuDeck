#!/bin/bash
#variables
HypseusSinge_emuName="Hypseus Singe"
HypseusSinge_emuType="$emuDeckEmuTypeAppImage"
HypseusSinge_emuPath="$HOME/Applications/hypseus-singe/Hypseus_Singe-x86_64.AppImage"
HypseusSinge_configFile="$HOME/.config/PCSX2/inis/PCSX2.ini"

#cleanupOlderThings
HypseusSinge_cleanup() {
	echo "NYI"
}

#Install
HypseusSinge_install() {
	echo "Begin Hypseus Singe Install"
	local showProgress="$1"

    if installEmuBI "$HypseusSinge_emuName" "$(getReleaseURLGH "DirtBagXon/hypseus-singe" ".tar.gz")" "" "tar.gz" "$showProgress"; then
        tar -xf "$HOME/Applications/hypseus-singe*.tar.gz" -C "$HOME/Applications/" && rm -rf "$HOME/Applications/hypseus-singe*.tar.gz"
    else
        return 1
    fi
}

#ApplyInitialSettings
HypseusSinge_init() {
	setMSG "Initializing $HypseusSinge_emuName settings."

	if [ -e "$HypseusSinge_configFile" ]; then
		mv -f "$HypseusSinge_configFile" "$HypseusSinge_configFile.bak"
	fi

	if ! "$HypseusSinge_emuPath" -testconfig; then # try to generate the config file. if it fails, insert one as a fallback.
		#fallback
		configEmuAI "$HypseusSinge_emuName" "config" "$HOME/.config/PCSX2" "$EMUDECKGIT/configs/HypseusSinge/.config/PCSX2" "true"
	fi

	HypseusSinge_setEmulationFolder
	HypseusSinge_setupStorage
	HypseusSinge_setupSaves
	HypseusSinge_setupControllers
	HypseusSinge_setCustomizations
	HypseusSinge_setRetroAchievements

}

#update
HypseusSinge_update(){
    echo "Begin HypseusSinge update"

    configEmuAI "HypseusSinge" "config" "$HOME/.config/HypseusSinge" "$EMUDECKGIT/configs/HypseusSinge"

    HypseusSinge_setEmulationFolder
    HypseusSinge_setupStorage
    HypseusSinge_setupSaves #?
    HypseusSinge_finalize
}



#ConfigurePaths
HypseusSinge_setEmulationFolder(){
    echo "Begin HypseusSinge Path Config"

    local prefpath_directoryOpt='pref-path: '
    local newprefpath_directoryOpt="$prefpath_directoryOpt""$storagePath/HypseusSinge/"
    changeLine "$prefpath_directoryOpt" "$newprefpath_directoryOpt" "$HypseusSinge_configFile"
}

#SetupSaves
HypseusSinge_setupSaves(){
    echo "Begin HypseusSinge save link"
    linkToSaveFolder HypseusSinge saves "$storagePath/HypseusSinge/ux0/user/00/savedata"
}


#SetupStorage
HypseusSinge_setupStorage(){
    echo "Begin HypseusSinge storage config"

    mkdir -p "$storagePath/HypseusSinge/ux0/app"
    unlink "$romsPath/psvita/InstalledGames"
    ln -s "$storagePath/HypseusSinge/ux0/app" "$romsPath/psvita/InstalledGames"

}


#WipeSettings
HypseusSinge_wipe(){
    echo "Begin HypseusSinge delete config directories"
    rm -rf "$HOME/.config/HypseusSinge"
}


#Uninstall
HypseusSinge_uninstall(){
    echo "Begin HypseusSinge uninstall"
    rm -rf "$HypseusSinge_emuPath"
}

#Migrate
HypseusSinge_migrate(){
echo "NYI"
}


#setABXYstyle
HypseusSinge_setABXYstyle(){
echo "NYI"
}

#WideScreenOn
HypseusSinge_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
HypseusSinge_wideScreenOff(){
echo "NYI"
}

#BezelOn
HypseusSinge_bezelOn(){
echo "NYI"
}

#BezelOff
HypseusSinge_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
HypseusSinge_finalize(){
    echo "Begin HypseusSinge finalize"
}

HypseusSinge_IsInstalled(){
    if [ -e "$HypseusSinge_emuPath/HypseusSinge" ]; then
        echo "true"
    else
        echo "false"
    fi
}

HypseusSinge_resetConfig(){
    HypseusSinge_init &>/dev/null && echo "true" || echo "false"
}


HypseusSinge_setResolution(){
	echo "NYI"
}