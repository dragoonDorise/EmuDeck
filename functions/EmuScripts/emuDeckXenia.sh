#!/bin/bash
#variables
Xenia_emuName="Xenia"
Xenia_emuType="windows"
Xenia_emuPath="${romsPath}xbox360/Xenia.exe"
Xenia_releaseURL="https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip"
Xenia_XeniaSettings="${romsPath}xbox360/settings.xml"

#cleanupOlderThings
Xenia.cleanup(){
	echo "NYI"
}

#Install
Xenia.install(){
	setMSG "Installing Xenia"		

	curl -L "$Xenia_releaseURL" --output "$romsPath"xbox360/xenia_master.zip 
	mkdir -p "$romsPath"xbox360/tmp
	unzip -o "$romsPath"xbox360/xenia_master.zip -d "$romsPath"xbox360/tmp 
	mv "$romsPath"xbox360/tmp/* "$romsPath"xbox360 
	rm -rf "$romsPath"xbox360/tmp 
	rm -f "$romsPath"xbox360/xenia_master.zip 		
}

#ApplyInitialSettings
Xenia.init(){
	setMSG "Initializing Xenia Config"
	rsync -avhp $EMUDECKGIT/configs/xenia/ "$romsPath"/xbox360 
}

#update
Xenia.update(){
	echo "NYI"
}

#ConfigurePaths
Xenia.setEmulationFolder(){
	echo "NYI"
}

#SetupSaves
Xenia.setupSaves(){
	echo "NYI"
}


#SetupStorage
Xenia.setupStorage(){
	echo "NYI"
}


#WipeSettings
Xenia.wipeSettings(){
	echo "NYI"
}


#Uninstall
Xenia.uninstall(){
    rm -rf "${Xenia_emuPath}"
}

#setABXYstyle
Xenia.setABXYstyle(){
    echo "NYI"
}

#Migrate
Xenia.migrate(){
   	echo "NYI" 
}

#WideScreenOn
Xenia.wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Xenia.wideScreenOff(){
	echo "NYI"
}

#BezelOn
Xenia.bezelOn(){
	echo "NYI"
}

#BezelOff
Xenia.bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
Xenia.finalize(){
    Xenia.cleanup
}

