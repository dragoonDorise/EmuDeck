#!/bin/bash
#variables
Cemu_emuName="Cemu"
Cemu_emuType="windows"
Cemu_emuPath="${romsPath}wiiu/cemu.exe"
Cemu_releaseURL="https://cemu.info/releases/cemu_1.26.2.zip"
Cemu_cemuSettings="${romsPath}wiiu/settings.xml"

#cleanupOlderThings
Cemu.cleanup(){
	echo "NYI"
}

#Install
Cemu.install(){
	setMSG "Installing $Cemu_emuName"		

	curl $Cemu_releaseURL --output "$romsPath"wiiu/cemu.zip 
	mkdir -p "$romsPath"wiiu/tmp
	unzip -o "$romsPath"wiiu/cemu.zip -d "$romsPath"wiiu/tmp
	mv "$romsPath"wiiu/tmp/cemu_*/ "$romsPath"wiiu/tmp/cemu/
	rsync -avzh "$romsPath"wiiu/tmp/cemu/ "$romsPath"wiiu/
	rm -rf "$romsPath"wiiu/tmp 
	rm -f "$romsPath"wiiu/cemu.zip
	
	cp "$EMUDECKGIT/tools/launchers/cemu.sh" "${toolsPath}"launchers/cemu.sh
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|" "${toolsPath}"launchers/cemu.sh
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/wiiu|${romsPath}wiiu|" "${toolsPath}"launchers/cemu.sh
	chmod +x "${toolsPath}"launchers/cemu.sh
	
}

#ApplyInitialSettings
Cemu.init(){
	setMSG "Initializing $Cemu_emuName settings."	
	rsync -avhp $EMUDECKGIT/configs/info.cemu.Cemu/data/cemu/ "${romsPath}wiiu"
    Cemu.setEmulationFolder
	Cemu.setupSaves
	Cemu.addSteamInputProfile
}

#update
Cemu.update(){
	setMSG "Updating $Cemu_emuName settings."	
	Cemu_cemuSettings="${romsPath}wiiu/settings.xml"
    if [ -f $Cemu_cemuSettings ]; then
	    mv -f $Cemu_cemuSettings $Cemu_cemuSettings.bak #retain cemusettings if it exists to stop wiping peoples mods. Just insert our search path for installed games.
	fi
    rsync -avhp $EMUDECKGIT/configs/info.cemu.Cemu/data/cemu/ "${romsPath}wiiu"
	if [ -f $Cemu_cemuSettings.bak ]; then
	   	rm $Cemu_cemuSettings
		mv -f $Cemu_cemuSettings.bak $Cemu_cemuSettings
	fi
    Cemu.setEmulationFolder
	Cemu.setupSaves
	Cemu.addSteamInputProfile
}

#ConfigurePaths
Cemu.setEmulationFolder(){
	setMSG "Setting $Cemu_emuName Emulation Folder"	
    Cemu_cemuSettings="${romsPath}wiiu/settings.xml"
	if [[ -f "${Cemu_cemuSettings}" ]]; then
		gamePathEntryFound=$(grep -rnw $Cemu_cemuSettings -e "z:${romsPath}wiiu/roms")
		if [[ $gamePathEntryFound == '' ]]; then 
			xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "z:${romsPath}wiiu/roms" $Cemu_cemuSettings
		fi
	fi
}

#SetupSaves
Cemu.setupSaves(){
	unlink "${savesPath}Cemu/saves" # Fix for previous bad symlink
	linkToSaveFolder Cemu saves "${romsPath}wiiu/mlc01/usr/save"
}


#SetupStorage
Cemu.setupStorage(){
	echo "NYI"
}


#WipeSettings
Cemu.wipeSettings(){
		echo "NYI"
   # rm -rf "${romPath}wiiu/"
   # prob not cause roms are here
}


#Uninstall
Cemu.uninstall(){
	setMSG "Uninstalling $Cemu_emuName."
    rm -rf "${Cemu_emuPath}"
}

#setABXYstyle
Cemu.setABXYstyle(){
    	echo "NYI"
}

#Migrate
Cemu.migrate(){
   	echo "NYI" 
}

#WideScreenOn
Cemu.wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Cemu.wideScreenOff(){
echo "NYI"
}

#BezelOn
Cemu.bezelOn(){
echo "NYI"
}

#BezelOff
Cemu.bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
Cemu.finalize(){
    Cemu.cleanup
}

Cemu.addSteamInputProfile(){
	setMSG "Adding $Cemu_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/cemu_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
