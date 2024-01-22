#!/bin/bash
#variables
RPCS3_emuName="RPCS3"
RPCS3_emuType="$emuDeckEmuTypeAppImage"
RPCS3_releaseURL="https://rpcs3.net/latest-appimage"
RPCS3_emuPath="$HOME/Applications/rpcs3.AppImage"
RPCS3_emuPathFlatpak="net.rpcs3.RPCS3"
RPCS3_VFSConf="$HOME/.config/rpcs3/vfs.yml"
RPCS3_migrationFlag="$HOME/.config/EmuDeck/.${RPCS3_emuName}MigrationCompleted"
RPCS3_configFile="$HOME/.config/rpcs3/config.yml"

#cleanupOlderThings
RPCS3_cleanup(){
	echo "NYI"
}

#Install
RPCS3_install(){
	setMSG "Installing RPCS3"

	# Migrates configurations to RPCS3 AppImage
	RPCS3_migrate
	
	# Install RPCS3
	local showProgress="$1"

	if installEmuAI "$RPCS3_emuName" "$RPCS3_releaseURL" "rpcs3" "$showProgress"; then # rpcs3.AppImage - needs to be lowercase yuzu for EsDE to find it
		:
	else
		return 1
	fi

	# Preserve flatpak permissions for old RPCS3 Install
	flatpak override net.rpcs3.RPCS3 --filesystem=host --user
}

#ApplyInitialSettings
RPCS3_init(){
	RPCS3_migrate
	configEmuAI "$RPCS3_emuName" "config" "$HOME/.config/rpcs3" "$EMUDECKGIT/configs/rpcs3" "true"
	RPCS3_setupStorage
	RPCS3_setEmulationFolder
	RPCS3_setupSaves
}

#update
RPCS3_update(){
	RPCS3_migrate
	configEmuAI "$RPCS3_emuName" "config" "$HOME/.config/rpcs3" "$EMUDECKGIT/configs/rpcs3"
	RPCS3_setupStorage
	RPCS3_setEmulationFolder
	RPCS3_setupSaves
}

#ConfigurePaths
RPCS3_setEmulationFolder(){
	iniFieldUpdate "$RPCS3_VFSConf" "" "/dev_hdd0/" "$storagePath/rpcs3/dev_hdd0/" ": "
	iniFieldUpdate "$RPCS3_VFSConf" "" "/games/" "$romsPath/ps3/" ": "
}

#SetupSaves
RPCS3_setupSaves(){
	linkToSaveFolder rpcs3 saves "${storagePath}/rpcs3/dev_hdd0/home/00000001/savedata"
	linkToSaveFolder rpcs3 trophy "${storagePath}/rpcs3/dev_hdd0/home/00000001/trophy"
}

#SetupStorage
RPCS3_setupStorage(){
	mkdir -p "$storagePath/rpcs3/"

	if [ ! -d "$storagePath"/rpcs3/dev_hdd0 ] && [ -d "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/" -o -d "$HOME/.config/rpcs3/" ]; then
		echo "RPCS3 HDD does not exist in storage path"

		echo -e ""
		setMSG "Moving RPCS3 HDD to the Emulation/storage folder"
		echo -e ""

		mkdir -p "$storagePath/rpcs3"

		if [ -d "$savesPath/rpcs3/dev_hdd0" ]; then
			mv -f "$savesPath"/rpcs3/dev_hdd0 "$storagePath"/rpcs3/

		elif [ -d "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" ]; then
			rsync -av "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" "$storagePath"/rpcs3/ && rm -rf "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0"

		elif [ -d "$HOME/.config/rpcs3/dev_hdd0" ]; then
			rsync -av "$HOME/.config/rpcs3/dev_hdd0" "$storagePath"/rpcs3/ && rm -rf "$HOME/.config/rpcs3/dev_hdd0"
		fi
	fi
}

#WipeSettings
RPCS3_wipe(){
	setMSG "Wiping $RPCS3_emuName settings."
	rm -rf "$HOME/.config/rpcs3"
	rm -rf "$HOME/.cache/rpcs3"
}


#Uninstall
RPCS3_uninstall(){
	setMSG "Uninstalling $RPCS3_emuName."
	rm -rf "$RPCS3_emuPath"
	RPCS3_wipe
}

#setABXYstyle
RPCS3_setABXYstyle(){
	 echo "NYI"
}


#Migrate
RPCS3_migrate(){
	echo "Begin RPCS3 Migration"

	# Migration
	if [ "$(RPCS3_IsMigrated)" != "true" ]; then
		#RPCS3 flatpak to appimage
		#From -- > to
		migrationTable=()
		migrationTable+=("$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3" "$HOME/.config/rpcs3")

		migrateAndLinkConfig "$RPCS3_emuName" "$migrationTable"
	fi

	echo "true"
}

#WideScreenOn
RPCS3_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
RPCS3_wideScreenOff(){
	echo "NYI"
}

#BezelOn
RPCS3_bezelOn(){
	echo "NYI"
}

#BezelOff
RPCS3_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
RPCS3_finalize(){
	echo "NYI"
}

RPCS3_IsInstalled(){
	local emuType=$1 # if empty we assume the caller doesn't care what type is installed, so we can check both
	# if flatpak type or no type is requested and we haven't yet migrated, check flatpak installation status
	if ([ "$emuType" == "$emuDeckEmuTypeFlatpak" ] || [ -z "$emuType" ]) && [ "$(RPCS3_IsMigrated)" != "true" ] && [ "$(isFpInstalled ""$RPCS3_emuPathFlatpak"")" == "true" ]; then
		echo "true"
	# we can stop here if flatpak type was requested - we already migrated and no longer want to care about flatpak and launcher / desktop shortcut updates
	elif [ "$emuType" == "$emuDeckEmuTypeFlatpak" ]; then
		echo "false"
	# appimage check
	elif [ -e "$RPCS3_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

RPCS3_IsMigrated(){
	if [ -f "$RPCS3_migrationFlag" ]; then
		echo "true"
	else
		echo "false"
	fi
}

RPCS3_resetConfig(){
	RPCS3_init &>/dev/null && echo "true" || echo "false"
}

RPCS3_setResolution(){

	case $rpcs3Resolution in
		"720P") res=100;;
		"1080P") res=150;;
		"1440P") res=200;;
		"4K") res=300;;
		*) echo "Error"; return 1;;
	esac

	RetroArch_setConfigOverride "Resolution Scale:" $res "$RPCS3_configFile"

	sed -i "s|Resolution Scale:=|Resolution Scale:|g" "$RPCS3_configFile"

}