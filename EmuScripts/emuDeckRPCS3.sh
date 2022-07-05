#!/bin/bash
#variables
emuName="RPCS3"
emuType="FlatPak"
emuPath="net.rpcs3.RPCS3"
releaseURL=""

#cleanupOlderThings
RPCS3.cleanup(){
 #na
}

#Install
RPCS3.install(){
	installEmuFP "${emuName}" "${emuPath}"	
	flatpak override ${emuPath} --filesystem=host --user	
}

#ApplyInitialSettings
RPCS3.init(){
	configEmuFP "${emuName}" "${emuPath}" "true"
	setupStorageRpcs3
	setEmulationFolderRpcs3
	setupSavesRpcs3
}

#update
RPCS3.update(){
	configEmuFP "${emuName}" "${emuPath}"
	setupStorageRpcs3
	setEmulationFolderRpcs3
	setupSavesRpcs3
}

#ConfigurePaths
RPCS3.setEmulationFolder(){
   #na
}

#SetupSaves
RPCS3.setupSaves(){
	linkToSaveFolder rpcs3 saves "${storagePath}rpcs3/dev_hdd0/home/00000001/savedata"
}


#SetupStorage
RPCS3.setupStorage(){
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
RPCS3.wipe(){
   rm -rf "$HOME/.var/app/$emuPath"
   # prob not cause roms are here
}


#Uninstall
RPCS3.uninstall(){
    flatpack uninstall $emuPath -y
}

#setABXYstyle
RPCS3.setABXYstyle(){
    
}

#Migrate
RPCS3.migrate(){
    
}

#WideScreenOn
RPCS3.wideScreenOn(){
#na
}

#WideScreenOff
RPCS3.wideScreenOff(){
#na
}

#BezelOn
RPCS3.bezelOn(){
#na
}

#BezelOff
RPCS3.bezelOff(){
#na
}

#finalExec - Extra stuff
RPCS3.finalize(){
	#na
}

