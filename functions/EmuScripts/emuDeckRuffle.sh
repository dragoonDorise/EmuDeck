#!/bin/bash

#variables
Ruffle_emuName="Ruffle"
Ruffle_emuType="Binary"
Ruffle_emuPath="$HOME/Applications/Ruffle"
Ruffle_configFile="$HOME/Applications/Ruffle/config.yml"

#cleanupOlderThings
Ruffle_cleanup(){
    echo "Begin Ruffle Cleanup"
}

#Install
Ruffle_install(){c
    echo "Begin Ruffle Install"
    local showProgress="$1"
    if installEmuBI "Ruffle" "$(getReleaseURLGH "ruffle-rs/ruffle" "linux-x86_64.tar.gz")" "Ruffle" "tar.gz" "$showProgress"; then
        tar -xf "$HOME/Applications/Ruffle.tar.gz" -d "$Ruffle_emuPath" && rm -rf "$HOME/Applications/Ruffle.tar.gz"
        chmod +x "$Ruffle_emuPath/ruffle"
    else
        return 1
    fi
}

#ApplyInitialSettings
Ruffle_init(){
    echo "Begin Ruffle Init"

    configEmuAI "Ruffle" "config" "$HOME/Applications/Ruffle" "$EMUDECKGIT/configs/Ruffle" "true"
    Ruffle_setEmulationFolder
    Ruffle_setupStorage
    Ruffle_setupSaves #?
    Ruffle_finalize
}

#update
Ruffle_update(){
    echo "Begin Ruffle update"

    configEmuAI "yuzu" "config" "$HOME/.config/Ruffle" "$EMUDECKGIT/configs/Ruffle"

    Ruffle_setEmulationFolder
    Ruffle_setupStorage
    Ruffle_setupSaves #?
    Ruffle_finalize
}



#ConfigurePaths
Ruffle_setEmulationFolder(){
    echo "Begin Ruffle Path Config"

    local prefpath_directoryOpt='pref-path: '
    local newprefpath_directoryOpt="$prefpath_directoryOpt""$storagePath/Ruffle/"
    changeLine "$prefpath_directoryOpt" "$newprefpath_directoryOpt" "$Ruffle_configFile"
}

#SetupSaves
Ruffle_setupSaves(){
    echo "Begin Ruffle save link"
    #moveSaveFolder Ruffle saves ??????
}


#SetupStorage
Ruffle_setupStorage(){
    echo "Begin Ruffle storage config"

    mkdir -p "$storagePath/Ruffle/"
    unlink "$romsPath/psvita/InstalledGames"
    ln -s "$storagePath/Ruffle/ux0/app" "$romsPath/psvita/InstalledGames"

}


#WipeSettings
Ruffle_wipe(){
    echo "Begin Ruffle delete config directories"
    rm -rf "$HOME/.config/Ruffle"
}


#Uninstall
Ruffle_uninstall(){
    echo "Begin Ruffle uninstall"
    rm -rf "$Ruffle_emuPath"
}

#Migrate
Ruffle_migrate(){
echo "NYI"
}


#setABXYstyle
Ruffle_setABXYstyle(){
echo "NYI"
}

#WideScreenOn
Ruffle_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Ruffle_wideScreenOff(){
echo "NYI"
}

#BezelOn
Ruffle_bezelOn(){
echo "NYI"
}

#BezelOff
Ruffle_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Ruffle_finalize(){
    echo "Begin Ruffle finalize"
}

Ruffle_IsInstalled(){
    if [ -e "$Ruffle_emuPath/Ruffle" ]; then
        echo "true"
    else
        echo "false"
    fi
}

Ruffle_resetConfig(){
    Ruffle_init &>/dev/null && echo "true" || echo "false"
}