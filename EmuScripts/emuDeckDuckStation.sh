#!/bin/bash
#variables
emuName="DuckStation"
emuType="FlatPak"
emuPath="org.duckstation.DuckStation"
releaseURL=""

#cleanupOlderThings
cleanupDuckStation() {
    #na
}

#Install
installDuckStation() {
    installEmuFP "${emuName}" "${emuPath}"
    flatpak override "${emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
initDuckStation() {
    configEmuFP "${emuName}" "${emuPath}" "true"
    setupStorageDuckStation
    setEmulationFolderDuckStation
    setupSavesDuckStation
}

#update
updateDuckStation() {
    configEmuFP "${emuName}" "${emuPath}"
    setupStorageDuckStation
    setEmulationFolderDuckStation
    setupSavesDuckStation
}

#ConfigurePaths
setEmulationFolderDuckStation() {
    configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
    gameDirOpt='RecursivePaths = '
    newGameDirOpt="${gameDirOpt}""${romsPath}psx"
    biosDir='SearchDirectory = '
    biosDirSetting="${biosDir}""${biosPath}"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
    sed -i "/${biosDir}/c\\${biosDirSetting}" "$configFile"
}

#SetupSaves
setupSavesDuckStation() {
    linkToSaveFolder duckstation saves "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/memcards"
    linkToSaveFolder duckstation states "$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/savestates"
}

#SetupStorage
setupStorageDuckStation() {
    #TBD
}

#WipeSettings
wipeDuckStation() {
    rm -rf "$HOME/.var/app/$emuPath"
    # prob not cause roms are here
}

#Uninstall
uninstallDuckStation() {
    flatpack uninstall "$emuPath" -y
}

#setABXYstyle
setABXYstyleDuckStation() {

}

#Migrate
migrateDuckStation() {

}

#WideScreenOn
wideScreenOnDuckStation() {
    configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = true'
    #aspectRatio='AspectRatio = '
    #aspectRatioSetting='AspectRatio = 0'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
    #sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#WideScreenOff
wideScreenOffDuckStation() {
    configFile="$HOME/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini"
    wideScreenHack='WidescreenHack = '
    wideScreenHackSetting='WidescreenHack = false'
    #aspectRatio='AspectRatio = '
    #aspectRatioSetting='AspectRatio = 0'
    sed -i "/${wideScreenHack}/c\\${wideScreenHackSetting}" "$configFile"
    #sed -i "/${aspectRatio}/c\\${aspectRatioSetting}" "$configFile"
}

#BezelOn
bezelOnDuckStation() {
    #na
}

#BezelOff
bezelOffDuckStation() {
    #na
}

#finalExec - Extra stuff
finalizeDuckStation() {
    #na
}
