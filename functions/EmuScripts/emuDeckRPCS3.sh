#!/bin/bash
#variables
RPCS3_remuName="RPCS3"
RPCS3_emuType="FlatPak"
RPCS3_emuPath="net.rpcs3.RPCS3"
RPCS3_releaseURL=""
RPCS3_VFSConf="$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/vfs.yml"

#cleanupOlderThings
RPCS3_cleanup(){
 echo "NYI"
}

#Install
RPCS3_install(){
	installEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}"	
	flatpak override "${RPCS3_emuPath}" --filesystem=host --user	
}

#ApplyInitialSettings
RPCS3_init(){
	configEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}" "true"
	RPCS3_setupStorage
	RPCS3_setEmulationFolder
	RPCS3_setupSaves
}

#update
RPCS3_update(){
	configEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}"
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