#!/bin/bash

#variables
Yuzu_emuName="Yuzu"
Yuzu_emuType="AppImage"
Yuzu_emuPath="$HOME/Applications/yuzu.AppImage"

#cleanupOlderThings
Yuzu.cleanup(){
    echo "Begin Yuzu Cleanup"
    #Fixes repeated Symlink for older installations
    cd "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/"
    unlink keys 
    cd "$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered/"
    unlink registered 
}

#Install
Yuzu.install(){
    echo "Begin Yuzu Install"
    installEmuAI "yuzu"  $(getLatestReleaseURLGH "yuzu-emu/yuzu-mainline" "AppImage") #needs to be lowercase yuzu for EsDE to find it.
    flatpak override org.yuzu_emu.yuzu --filesystem=host --user # still doing this, as we do link the appimage / flatpak config. if the user ever decides to install the flatpak, we do want it to work.
}

#ApplyInitialSettings
Yuzu.init(){
    echo "Begin Yuzu Init"
    
    Yuzu.migrate
	
    configEmuAI "yuzu" "config" "$HOME/.config/yuzu" "$HOME/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/config/yuzu" "true"
	configEmuAI "yuzu" "data" "$HOME/.local/share/yuzu" "$HOME/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/data/yuzu" "true"
    
    Yuzu.setEmulationFolder
    Yuzu.setupStorage

}

#update
Yuzu.update(){
    echo "Begin Yuzu update"

    Yuzu.migrate
	
    configEmuAI "yuzu" "config" "$HOME/.config/yuzu" "$HOME/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/config/yuzu"
	configEmuAI "yuzu" "data" "$HOME/.local/share/yuzu" "$HOME/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/data/yuzu"
    
    Yuzu.setEmulationFolder
    Yuzu.setupStorage
    
}



#ConfigurePaths
Yuzu.setEmulationFolder(){
    echo "Begin Yuzu Path Config"
    configFile="$HOME/.config/yuzu/qt-config.ini"
    screenshotDirOpt='Screenshots\\screenshot_path='
    gameDirOpt='Paths\\gamedirs\\4\\path='
    dumpDirOpt='dump_directory='
    loadDir='load_directory='
    nandDirOpt='nand_directory='
    sdmcDirOpt='sdmc_directory='
    tasDirOpt='tas_directory='
    newScreenshotDirOpt='Screenshots\\screenshot_path='"${storagePath}yuzu/screenshots"
    newGameDirOpt='Paths\\gamedirs\\4\\path='"${romsPath}switch"
    newDumpDirOpt='dump_directory='"${storagePath}yuzu/dump"
    newLoadDir='load_directory='"${storagePath}yuzu/load"
    newNandDirOpt='nand_directory='"${storagePath}yuzu/nand"
    newSdmcDirOpt='sdmc_directory='"${storagePath}yuzu/sdmc"
    newTasDirOpt='tas_directory='"${storagePath}yuzu/tas"


    sed -i "/${screenshotDirOpt}/c\\${newScreenshotDirOpt}" $configFile
    sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" $configFile
    sed -i "/${dumpDirOpt}/c\\${newDumpDirOpt}" $configFile
    sed -i "/${loadDir}/c\\${newLoadDir}" $configFile
    sed -i "/${nandDirOpt}/c\\${newNandDirOpt}" $configFile
    sed -i "/${sdmcDirOpt}/c\\${newSdmcDirOpt}" $configFile
    sed -i "/${tasDirOpt}/c\\${newTasDirOpt}" $configFile

    #Setup Bios symlinks
    unlink "${biosPath}yuzu/keys"
    unlink "${biosPath}yuzu/firmware"

    mkdir -p "$HOME/.local/share/yuzu/keys/"
    mkdir -p "${storagePath}yuzu/nand/system/Contents/registered/"

    ln -sn "$HOME/.local/share/yuzu/keys/" "${biosPath}yuzu/keys"
    ln -sn "${storagePath}yuzu/nand/system/Contents/registered/" "${biosPath}yuzu/firmware"

    touch "${storagePath}yuzu/nand/system/Contents/registered/putfirmwarehere.txt"

}

#SetupSaves
Yuzu.setupSaves(){
    echo "Begin Yuzu save link"
	unlink "${savesPath}yuzu/saves" # Fix for previous bad symlink
	linkToSaveFolder yuzu saves "${storagePath}yuzu/nand/user/save/"
}


#SetupStorage
Yuzu.setupStorage(){
    echo "Begin Yuzu storage config"
    mkdir -p ${storagePath}yuzu/dump
    mkdir -p ${storagePath}yuzu/load
    mkdir -p ${storagePath}yuzu/sdmc
    mkdir -p ${storagePath}yuzu/nand
    mkdir -p ${storagePath}yuzu/screenshots
    mkdir -p ${storagePath}yuzu/tas
}


#WipeSettings
Yuzu.wipe(){
    echo "Begin Yuzu delete config directories"
    rm -rf "$HOME/.config/yuzu"
    rm -rf "$HOME/.local/share/yuzu"
}


#Uninstall
Yuzu.uninstall(){
    echo "Begin Yuzu uninstall"
    rm -rf $emuPath
}


#Migrate
Yuzu.migrate(){
    echo "Begin Yuzu Migration"
    emu="Yuzu"
	migrationFlag="$HOME/emudeck/.${emu}MigrationCompleted"
	#check if we have a nomigrateflag for $emu
	if [ ! -f "$migrationFlag" ]; then	
		#yuzu flatpak to appimage
		#From -- > to
		migrationTable=()
		migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu" "$HOME/.local/share/yuzu")
		migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/config/yuzu" "$HOME/.config/yuzu")

		migrateAndLinkConfig $emu $migrationTable
	fi

	#move data from hidden folders out to these folders in case the user already put stuff here.
	origPath="$HOME/.local/share/"

	Yuzu.setupStorage
	
	rsync -av ${origPath}yuzu/dump ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/dump
	rsync -av ${origPath}yuzu/load ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/load
	rsync -av ${origPath}yuzu/sdmc ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/sdmc
	rsync -av ${origPath}yuzu/nand ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/nand
	rsync -av ${origPath}yuzu/screenshots ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/screenshots
	rsync -av ${origPath}yuzu/tas ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/tas
}

#setABXYstyle
Yuzu.setABXYstyle(){
echo "NYI"
}

#WideScreenOn
Yuzu.wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Yuzu.wideScreenOff(){
echo "NYI"
}

#BezelOn
Yuzu.bezelOn(){
echo "NYI"
}

#BezelOff
Yuzu.bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Yuzu.finalize(){
    echo "Begin Yuzu finalize"
    Yuzu.cleanup
}

