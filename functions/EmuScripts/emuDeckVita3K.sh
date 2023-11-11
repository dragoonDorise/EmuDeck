#!/bin/bash

#variables
Vita3K_emuName="Vita3K"
Vita3K_emuType="Binary"
Vita3K_emuPath="$HOME/Applications/Vita3K"
Vita3K_configFile="$HOME/.config/Vita3K/config.yml"

#cleanupOlderThings
Vita3K_cleanup(){
    echo "Begin Vita3K Cleanup"
}

#Install
Vita3K_install(){
    echo "Begin Vita3K Install"
    local showProgress="$1"
    if installEmuBI "Vita3K" "https://github.com/Vita3K/Vita3K/releases/download/continuous/ubuntu-latest.zip" "Vita3K" "zip" "$showProgress"; then
        unzip -o "$HOME/Applications/Vita3K.zip" -d "$Vita3K_emuPath" && rm -rf "$HOME/Applications/Vita3K.zip"
        chmod +x "$Vita3K_emuPath/Vita3K"
    else
        return 1
    fi
}

#ApplyInitialSettings
Vita3K_init(){
    echo "Begin Vita3K Init"

    configEmuAI "Vita3K" "config" "$HOME/.config/Vita3K" "$EMUDECKGIT/configs/Vita3K" "true"
    Vita3K_setEmulationFolder
    Vita3K_setupStorage
    Vita3K_setupSaves #?
    Vita3K_finalize
}

#update
Vita3K_update(){
    echo "Begin Vita3K update"

    configEmuAI "Vita3K" "config" "$HOME/.config/Vita3K" "$EMUDECKGIT/configs/Vita3K"

    Vita3K_setEmulationFolder
    Vita3K_setupStorage
    Vita3K_setupSaves #?
    Vita3K_finalize
}



#ConfigurePaths
Vita3K_setEmulationFolder(){
    echo "Begin Vita3K Path Config"

    local prefpath_directoryOpt='pref-path: '
    local newprefpath_directoryOpt="$prefpath_directoryOpt""$storagePath/Vita3K/"
    changeLine "$prefpath_directoryOpt" "$newprefpath_directoryOpt" "$Vita3K_configFile"
}

#SetupSaves
Vita3K_setupSaves(){
    echo "Begin Vita3K save link"
    linkToSaveFolder Vita3K saves "$storagePath/Vita3K/ux0/user/00/savedata"
}


#SetupStorage
Vita3K_setupStorage(){
    echo "Begin Vita3K storage config"

    mkdir -p "$storagePath/Vita3K/"
    unlink "$romsPath/psvita/InstalledGames"
    ln -s "$storagePath/Vita3K/ux0/app" "$romsPath/psvita/InstalledGames"

}


#WipeSettings
Vita3K_wipe(){
    echo "Begin Vita3K delete config directories"
    rm -rf "$HOME/.config/Vita3K"
}


#Uninstall
Vita3K_uninstall(){
    echo "Begin Vita3K uninstall"
    rm -rf "$Vita3K_emuPath"
}

#Migrate
Vita3K_migrate(){
echo "NYI"
}


#setABXYstyle
Vita3K_setABXYstyle(){
echo "NYI"
}

#WideScreenOn
Vita3K_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Vita3K_wideScreenOff(){
echo "NYI"
}

#BezelOn
Vita3K_bezelOn(){
echo "NYI"
}

#BezelOff
Vita3K_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Vita3K_finalize(){
    echo "Begin Vita3K finalize"
}

Vita3K_IsInstalled(){
    if [ -e "$Vita3K_emuPath/Vita3K" ]; then
        echo "true"
    else
        echo "false"
    fi
}

Vita3K_resetConfig(){
    Vita3K_init &>/dev/null && echo "true" || echo "false"
}
