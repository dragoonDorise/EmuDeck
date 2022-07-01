#!/bin/bash
#variables
emuName="RPCS3"
emuType="FlatPak"
emuPath="net.rpcs3.RPCS3"
releaseURL=""

#cleanupOlderThings
cleanupRpcs3(){
 #na
}

#Install
installRpcs3(){
	installEmuFP "${emuName}" "${emuPath}"	
	flatpak override ${emuPath} --filesystem=host --user	
}

#ApplyInitialSettings
initRpcs3(){
	configEmuFP "${emuName}" "${emuPath}" "true"
	setupStorageRpcs3
	setEmulationFolderRpcs3
	setupSavesRpcs3
}

#update
updateRpcs3(){
	configEmuFP "${emuName}" "${emuPath}"
	setupStorageRpcs3
	setEmulationFolderRpcs3
	setupSavesRpcs3
}

#ConfigurePaths
setEmulationFolderRpcs3(){
   #na
}

#SetupSaves
setupSavesRpcs3(){
	linkToSaveFolder rpcs3 saves "${storagePath}rpcs3/dev_hdd0/home/00000001/savedata"
}


#SetupStorage
setupStorageRpcs3(){
 	sed -i 's| $(EmulatorDir)dev_hdd0/| '$storagePath'/rpcs3/dev_hdd0/|g' $HOME/.var/app/${emuPath}/config/rpcs3/vfs.yml 
	mkdir -p $storagePath/rpcs3/

	if [ ! -d "$storagePath"rpcs3/dev_hdd0 ] && [ -d "$HOME/.var/app/${emuPath}/" ];then
		echo "rpcs3 hdd does not exist in storagepath."
		#update config file for the new loc $(emulatorDir) is in the file. made this annoying.
		rpcs3VFSConf="$HOME/.var/app/${emuPath}/config/rpcs3/vfs.yml"
		rpcs3DevHDD0Line="/dev_hdd0/: ${storagePath}rpcs3/dev_hdd0/"
		sed -i "/dev_hdd0/c\\${rpcs3DevHDD0Line}" $rpcs3VFSConf 

		echo -e ""
		setMSG "Moving rpcs3 HDD to the Emulation/storage folder"			
		echo -e ""
		
		mkdir -p "$storagePath/rpcs3" 

		if [ -d "$savesPath/rpcs3/dev_hdd0" ]; then
			mv -f "$savesPath"rpcs3/dev_hdd0 "$storagePath"rpcs3/

		elif [ -d "$HOME/.var/app/${emuPath}/config/rpcs3/dev_hdd0" ]; then	
			rsync -av "$HOME/.var/app/${emuPath}/config/rpcs3/dev_hdd0" "$storagePath"rpcs3/ && rm -rf "$HOME/.var/app/${emuPath}/config/rpcs3/dev_hdd0"

		fi
	fi
}


#WipeSettings
wipeRpcs3(){
   rm -rf "$HOME/.var/app/$emuPath"
   # prob not cause roms are here
}


#Uninstall
uninstallRpcs3(){
    flatpack uninstall $emuPath -y
}

#setABXYstyle
setABXYstyleRpcs3(){
    
}

#Migrate
migrateRpcs3(){
    
}

#WideScreenOn
wideScreenOnRpcs3(){
#na
}

#WideScreenOff
wideScreenOffRpcs3(){
#na
}

#BezelOn
bezelOnRpcs3(){
#na
}

#BezelOff
bezelOffRpcs3(){
#na
}

#finalExec - Extra stuff
finalizeRpcs3(){
	#na
}

