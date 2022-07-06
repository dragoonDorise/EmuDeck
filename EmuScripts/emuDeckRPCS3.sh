#!/bin/bash
#variables
RPCS3_remuName="RPCS3"
RPCS3_emuType="FlatPak"
RPCS3_emuPath="net.rpcs3.RPCS3"
RPCS3_releaseURL=""

#cleanupOlderThings
RPCS3.cleanup(){
 echo "NYI"
}

#Install
RPCS3.install(){
	installEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}"	
	flatpak override ${RPCS3_emuPath} --filesystem=host --user	
}

#ApplyInitialSettings
RPCS3.init(){
	configEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}" "true"
	setupStorageRpcs3
	setEmulationFolderRpcs3
	setupSavesRpcs3
}

#update
RPCS3.update(){
	configEmuFP "${RPCS3_remuName}" "${RPCS3_emuPath}"
	setupStorageRpcs3
	setEmulationFolderRpcs3
	setupSavesRpcs3
}

#ConfigurePaths
RPCS3.setEmulationFolder(){
   echo "NYI"
}

#SetupSaves
RPCS3.setupSaves(){
	linkToSaveFolder rpcs3 saves "${storagePath}rpcs3/dev_hdd0/home/00000001/savedata"
}


#SetupStorage
RPCS3.setupStorage(){
 	sed -i 's| $(EmulatorDir)dev_hdd0/| '$storagePath'/rpcs3/dev_hdd0/|g' $HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/vfs.yml 
	mkdir -p $storagePath/rpcs3/

	if [ ! -d "$storagePath"rpcs3/dev_hdd0 ] && [ -d "$HOME/.var/app/${RPCS3_emuPath}/" ];then
		echo "rpcs3 hdd does not exist in storagepath."
		#update config file for the new loc $(emulatorDir) is in the file. made this annoying.
		rpcs3VFSConf="$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/vfs.yml"
		rpcs3DevHDD0Line="/dev_hdd0/: ${storagePath}rpcs3/dev_hdd0/"
		sed -i "/dev_hdd0/c\\${rpcs3DevHDD0Line}" $rpcs3VFSConf 

		echo -e ""
		setMSG "Moving rpcs3 HDD to the Emulation/storage folder"			
		echo -e ""
		
		mkdir -p "$storagePath/rpcs3" 

		if [ -d "$savesPath/rpcs3/dev_hdd0" ]; then
			mv -f "$savesPath"rpcs3/dev_hdd0 "$storagePath"rpcs3/

		elif [ -d "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/dev_hdd0" ]; then	
			rsync -av "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/dev_hdd0" "$storagePath"rpcs3/ && rm -rf "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/dev_hdd0"

		fi
	fi
}


#WipeSettings
RPCS3.wipe(){
   rm -rf "$HOME/.var/app/$RPCS3_emuPath"
   # prob not cause roms are here
}


#Uninstall
RPCS3.uninstall(){
    flatpack uninstall $RPCS3_emuPath -y
}

#setABXYstyle
RPCS3.setABXYstyle(){
 	echo "NYI"   
}

#Migrate
RPCS3.migrate(){
  	echo "NYI"  
}

#WideScreenOn
RPCS3.wideScreenOn(){
echo "NYI"
}

#WideScreenOff
RPCS3.wideScreenOff(){
echo "NYI"
}

#BezelOn
RPCS3.bezelOn(){
echo "NYI"
}

#BezelOff
RPCS3.bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
RPCS3.finalize(){
	echo "NYI"
}

