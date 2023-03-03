#!/bin/bash

#variables
Yuzu_emuName="Yuzu"
Yuzu_emuType="AppImage"
Yuzu_emuPath="$HOME/Applications/yuzu.AppImage"
YuzuEA_emuPath="$HOME/Applications/yuzu-ea.AppImage"

#cleanupOlderThings
Yuzu_cleanup(){
    echo "Begin Yuzu Cleanup"
    #Fixes repeated Symlink for older installations
    unlink "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/keys"
    unlink "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered/registered"
    
}

#Install
Yuzu_install(){
    echo "Begin Yuzu Install"
    
    local showProgress=$1
    local lastVerFile="$HOME/emudeck/yuzu.ver"
    local latestVer=$(curl -fSs "https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases" | jq -r '[ .[].tag_name ][0]')
    local success="false"
    if installEmuAI "yuzu" "$(getReleaseURLGH "yuzu-emu/yuzu-mainline" "AppImage")" "" "$showProgress" "$lastVerFile" "$latestVer"; then #needs to be lowercase yuzu for EsDE to find it.
        success="true"
    fi

    local successEA="false"
    if YuzuEA_install "$showProgress"; then # call the EA install. If the user has the token in the right spot, it will download EA as well for them.
        successEA="true"
    fi

    if [ "$success" != "true" ] || [ "$successEA" != "true" ]; then
        return 1
    fi
}

YuzuEA_install(){

local jwtHost="https://api.yuzu-emu.org/jwt/installer/"
local yuzuEaHost="https://api.yuzu-emu.org/downloads/earlyaccess/"
local yuzuEaMetadata=$(curl -fSs ${yuzuEaHost})
local fileToDownload=$(echo $yuzuEaMetadata | jq -r '.files[] | select(.name|test(".*.AppImage")).url')
local currentVer=$(echo $yuzuEaMetadata | jq -r '.files[] | select(.name|test(".*.AppImage")).name')
local tokenFile="$HOME/emudeck/yuzu-ea-token.txt"
local lastVerFile="$HOME/emudeck/yuzu-ea.ver"
local showProgress="$1"

if [ -e "$tokenFile" ]; then

    if [ "$currentVer" == "$(cat ${lastVerFile})" ]; then

        echo "no need to update."

    elif [ -z $currentVer ]; then
        
        echo "couldn't get metadata."
        return 1

    else

        echo "updating"
        read user auth <<< $( base64 -d -i "${tokenFile}" | awk -F":" '{print $1" "$2}' )

        if [[ -n "$user" && -n "$auth" ]]; then

            echo "get bearer token"
            BEARERTOKEN=$(curl -X POST ${jwtHost} -H "X-Username: ${user}" -H "X-Token: ${auth}" -H "User-Agent: EmuDeck")

            echo "download ea appimage"
            #response=$(curl -f -X GET ${fileToDownload} --write-out '%{http_code}' -H "Accept: application/json" -H "Authorization: Bearer ${BEARERTOKEN}" -o "${YuzuEA_emuPath}.temp")
            if safeDownload "$yuzu-ea" "$fileToDownload" "${YuzuEA_emuPath}" "$showProgress" "Authorization: Bearer ${BEARERTOKEN}"; then
                chmod +x "$YuzuEA_emuPath"
                echo "latest version $currentVer > $lastVerFile"
                echo ${currentVer} > "${lastVerFile}"
            else
                return 1
            fi

        else

            echo "Token malformed"
            return 1

        fi

    fi

else

	echo "Token Not Found"
    
fi

# if we have yuzu-ea.AppImage, launcher will use that instead of mainline one so we can decorate shortcut
if [ -e "$YuzuEA_emuPath" ]; then
    yuzuShortcut="$HOME/.local/share/applications/yuzu.desktop"
    if [ -e "$yuzuShortcut" ]; then
        desktopShortcutFieldUpdate "$yuzuShortcut" "Name" "yuzu-EA AppImage"
    fi
fi

}

#ApplyInitialSettings
Yuzu_init(){
    echo "Begin Yuzu Init"
    
    Yuzu_migrate
    
    configEmuAI "yuzu" "config" "$HOME/.config/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/config/yuzu" "true"
    configEmuAI "yuzu" "data" "$HOME/.local/share/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/data/yuzu" "true"
    
    Yuzu_setEmulationFolder
    Yuzu_setupStorage
    Yuzu_setupSaves
    Yuzu_finalize

}

#update
Yuzu_update(){
    echo "Begin Yuzu update"

    Yuzu_migrate
    
    configEmuAI "yuzu" "config" "$HOME/.config/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/config/yuzu"
    configEmuAI "yuzu" "data" "$HOME/.local/share/yuzu" "$EMUDECKGIT/configs/org.yuzu_emu.yuzu/data/yuzu"
    
    Yuzu_setEmulationFolder
    Yuzu_setupStorage
    Yuzu_setupSaves
    Yuzu_finalize
}



#ConfigurePaths
Yuzu_setEmulationFolder(){
    echo "Begin Yuzu Path Config"
    configFile="$HOME/.config/yuzu/qt-config.ini"
    screenshotDirOpt='Screenshots\\screenshot_path='
    gameDirOpt='Paths\\gamedirs\\4\\path='
    dumpDirOpt='dump_directory='
    loadDir='load_directory='
    nandDirOpt='nand_directory='
    sdmcDirOpt='sdmc_directory='
    tasDirOpt='tas_directory='
    newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}/yuzu/screenshots"
    newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}/switch"
    newDumpDirOpt='dump_directory='"${storagePath}/yuzu/dump"
    newLoadDir='load_directory='"${storagePath}/yuzu/load"
    newNandDirOpt='nand_directory='"${storagePath}/yuzu/nand"
    newSdmcDirOpt='sdmc_directory='"${storagePath}/yuzu/sdmc"
    newTasDirOpt='tas_directory='"${storagePath}/yuzu/tas"


    sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" "$configFile"
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$configFile"
    sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" "$configFile"
    sed -i "/${loadDir}/c\\${newLoadDir}" "$configFile"
    sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" "$configFile"
    sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" "$configFile"
    sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" "$configFile"

    #Setup Bios symlinks
    unlink "${biosPath}/yuzu/keys" 2>/dev/null
    unlink "${biosPath}/yuzu/firmware" 2>/dev/null

    mkdir -p "$HOME/.local/share/yuzu/keys/"
    mkdir -p "${storagePath}/yuzu/nand/system/Contents/registered/"

    ln -sn "$HOME/.local/share/yuzu/keys/" "${biosPath}/yuzu/keys"
    ln -sn "${storagePath}/yuzu/nand/system/Contents/registered/" "${biosPath}/yuzu/firmware"

    touch "${storagePath}/yuzu/nand/system/Contents/registered/putfirmwarehere.txt"

}

#SetupSaves
Yuzu_setupSaves(){
    echo "Begin Yuzu save link"
    unlink "${savesPath}/yuzu/saves" 2>/dev/null # Fix for previous bad symlink2>/dev/null
    linkToSaveFolder yuzu saves "${storagePath}/yuzu/nand/user/save/"
}


#SetupStorage
Yuzu_setupStorage(){
    echo "Begin Yuzu storage config"
    mkdir -p "${storagePath}/yuzu/dump"
    mkdir -p "${storagePath}/yuzu/load"
    mkdir -p "${storagePath}/yuzu/sdmc"
    mkdir -p "${storagePath}/yuzu/nand"
    mkdir -p "${storagePath}/yuzu/screenshots"
    mkdir -p "${storagePath}/yuzu/tas"
}


#WipeSettings
Yuzu_wipe(){
    echo "Begin Yuzu delete config directories"
    rm -rf "$HOME/.config/yuzu"
    rm -rf "$HOME/.local/share/yuzu"
}


#Uninstall
Yuzu_uninstall(){
    echo "Begin Yuzu uninstall"
    rm -rf "$Yuzu_emuPath"
    YuzuEA_uninstall
}

YuzuEA_uninstall(){
    echo "Begin Yuzu EA uninstall"
    rm -rf "$YuzuEA_emuPath"
}

#Migrate
Yuzu_migrate(){
    echo "Begin Yuzu Migration"
    emu="Yuzu"
    migrationFlag="$HOME/.config/EmuDeck/.${emu}MigrationCompleted"
    #check if we have a nomigrateflag for $emu
    if [ ! -f "$migrationFlag" ]; then	
        #yuzu flatpak to appimage
        #From -- > to
        migrationTable=()
        migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu" "$HOME/.local/share/yuzu")
        migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/config/yuzu" "$HOME/.config/yuzu")

      # migrateAndLinkConfig "$emu" "$migrationTable"
    fi

    #move data from hidden folders out to these folders in case the user already put stuff here.
    origPath="$HOME/.local/share/"

    Yuzu_setupStorage
    
    rsync -av "${origPath}yuzu/dump" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/dump"
    rsync -av "${origPath}yuzu/load" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/load"
    rsync -av "${origPath}yuzu/sdmc" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/sdmc"
    rsync -av "${origPath}yuzu/nand" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/nand"
    rsync -av "${origPath}yuzu/screenshots" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/screenshots"
    rsync -av "${origPath}yuzu/tas" "${storagePath}/yuzu/" && rm -rf "${origPath}yuzu/tas"
}

#setABXYstyle
Yuzu_setABXYstyle(){
echo "NYI"
}

#WideScreenOn
Yuzu_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Yuzu_wideScreenOff(){
echo "NYI"
}

#BezelOn
Yuzu_bezelOn(){
echo "NYI"
}

#BezelOff
Yuzu_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Yuzu_finalize(){
    echo "Begin Yuzu finalize"
    Yuzu_cleanup
}

Yuzu_IsInstalled(){
	if [ -e "$Yuzu_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

YuzuEA_IsInstalled(){
	if [ -e "$YuzuEA_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Yuzu_resetConfig(){
	Yuzu_init &>/dev/null && echo "true" || echo "false"
}