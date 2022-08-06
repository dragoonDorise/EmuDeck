#!/bin/bash
#variables
Xenia_emuName="Xenia"
Xenia_emuType="windows"
Xenia_emuPath="${romsPath}/xbox360/Xenia.exe"
Xenia_releaseURL="https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip"
Xenia_XeniaSettings="${romsPath}/xbox360/settings.xml"

#cleanupOlderThings
Xenia_cleanup(){
	echo "NYI"
}

#Install
Xenia_install(){
	setMSG "Installing Xenia"		

	curl -L "$Xenia_releaseURL" --output "$romsPath"/xbox360/xenia_master.zip 
	mkdir -p "$romsPath"/xbox360/tmp
	unzip -o "$romsPath"/xbox360/xenia_master.zip -d "$romsPath"/xbox360/tmp 
	mv "$romsPath"/xbox360/tmp/* "$romsPath"/xbox360 
	rm -rf "$romsPath"/xbox360/tmp 
	rm -f "$romsPath"/xbox360/xenia_master.zip 		
}

#ApplyInitialSettings
Xenia_init(){
	setMSG "Initializing Xenia Config"
	rsync -avhp $EMUDECKGIT/configs/xenia/ "$romsPath"/xbox360 
}

#update
Xenia_update(){
	echo "NYI"
}

#ConfigurePaths
Xenia_setEmulationFolder(){
	echo "NYI"
}

#SetupSaves
Xenia_setupSaves(){
	echo "NYI"
}


#SetupStorage
Xenia_setupStorage(){
	echo "NYI"
}


#WipeSettings
Xenia_wipeSettings(){
	echo "NYI"
}


#Uninstall
Xenia_uninstall(){
    rm -rf "${Xenia_emuPath}"
}

#setABXYstyle
Xenia_setABXYstyle(){
    echo "NYI"
}

#Migrate
Xenia_migrate(){
   	echo "NYI" 
}

#WideScreenOn
Xenia_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Xenia_wideScreenOff(){
	echo "NYI"
}

#BezelOn
Xenia_bezelOn(){
	echo "NYI"
}

#BezelOff
Xenia_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
Xenia_finalize(){
    Xenia_cleanup
}

