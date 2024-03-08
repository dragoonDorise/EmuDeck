#!/bin/bash
#variables
RPCS3_remuName="RPCS3"
RPCS3_emuType="FlatPak"
RPCS3_emuPath="net.rpcs3.RPCS3"
RPCS3_releaseURL=""
RPCS3_VFSConf="$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/vfs.yml"
RPCS3_configFile="$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/config.yml"

#cleanupOlderThings
RPCS3_cleanup(){
 echo "NYI"
}

#Install
RPCS3_install(){
	installEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}"
}

#ApplyInitialSettings
RPCS3_init(){
	configEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}" "true"
	RPCS3_setupStorage
	RPCS3_setEmulationFolder
	RPCS3_setupSaves
	RPCS3_addESConfig
	#SRM_createParsers
}

#Fix for autoupdate
Rpcsx3_install(){
	RPCS3_install
}

#update
RPCS3_update(){
	configEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}"
	RPCS3_setupStorage
	RPCS3_setEmulationFolder
	RPCS3_setupSaves
	RPCS3_addESConfig
}

#ConfigurePaths
RPCS3_setEmulationFolder(){
   iniFieldUpdate "$RPCS3_VFSConf" "" "/dev_hdd0/" "$storagePath/rpcs3/dev_hdd0/" ": "
   iniFieldUpdate "$RPCS3_VFSConf" "" "/games/" "$romsPath/ps3/" ": "
}

#SetupSaves
RPCS3_setupSaves(){
	linkToSaveFolder rpcs3 saves "${storagePath}/rpcs3/dev_hdd0/home/00000001/savedata"
}


#SetupStorage
RPCS3_setupStorage(){

	mkdir -p "$storagePath/rpcs3/"

	if [ ! -d "$storagePath"/rpcs3/dev_hdd0 ] && [ -d "$HOME/.var/app/${RPCS3_emuPath}/" ];then
		echo "rpcs3 hdd does not exist in storagepath."

		echo -e ""
		setMSG "Moving rpcs3 HDD to the Emulation/storage folder"
		echo -e ""

		mkdir -p "$storagePath/rpcs3"

		if [ -d "$savesPath/rpcs3/dev_hdd0" ]; then
			mv -f "$savesPath"/rpcs3/dev_hdd0 "$storagePath"/rpcs3/

		elif [ -d "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/dev_hdd0" ]; then
			rsync -av "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/dev_hdd0" "$storagePath"/rpcs3/ && rm -rf "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/dev_hdd0"

		fi
	fi
	mkdir -p "$storagePath/rpcs3/dev_hdd0/game"
}

RPCS3_addESConfig(){
	#insert RPCS3 custom system if it doesn't exist, but the file does
	# LD_LIBRARY_PATH=/usr/lib:/usr/local/lib tested and works on both the Flatpak and the AppImage
	if [[ $(grep -rnw "$es_systemsFile" -e 'ps3') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'ps3' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Sony PlayStation 3' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/ps3' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.desktop .ps3 .PS3 .ps3dir .PS3DIR' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "LD_LIBRARY_PATH=/usr/lib:/usr/local/lib %ENABLESHORTCUTS% %EMULATOR_OS-SHELL% %ROM%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "RPCS3 Shortcut (Standalone)" \
		--subnode '$newSystem' --type elem --name 'commandN' -v "LD_LIBRARY_PATH=/usr/lib:/usr/local/lib %EMULATOR_RPCS3% --no-gui %ROM%" \
		--insert '$newSystem/commandN' --type attr --name 'label' --value "RPCS3 Directory (Standalone)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'ps3' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'ps3' \
		-r 'systemList/system/commandP' -v 'command' \
		-r 'systemList/system/commandN' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi
    #Custom Systems config end

}


#WipeSettings
RPCS3_wipe(){
   rm -rf "$HOME/.var/app/$RPCS3_emuPath"
   # prob not cause roms are here
}


#Uninstall
RPCS3_uninstall(){
	flatpak uninstall "$RPCS3_emuPath" --user -y
}

#setABXYstyle
RPCS3_setABXYstyle(){
	 echo "NYI"
}

#Migrate
RPCS3_migrate(){
	  echo "NYI"
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
	isFpInstalled "$RPCS3_emuPath"
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