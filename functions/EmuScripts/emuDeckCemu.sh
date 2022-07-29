#!/bin/bash
#variables
Cemu_emuName="Cemu"
Cemu_emuType="windows"
Cemu_emuPath="${romsPath}/wiiu/cemu.exe"
Cemu_releaseURL="https://cemu.info/releases/cemu_1.26.2.zip"
Cemu_cemuSettings="${romsPath}/wiiu/settings.xml"

#cleanupOlderThings
Cemu_cleanup(){
	echo "NYI"
}

#Install
Cemu_install(){
	setMSG "Installing $Cemu_emuName"		

	curl $Cemu_releaseURL --output "$romsPath"/wiiu/cemu.zip 
	mkdir -p "$romsPath"/wiiu/tmp
	unzip -o "$romsPath"/wiiu/cemu.zip -d "$romsPath"/wiiu/tmp
	mv "$romsPath"/wiiu/tmp/cemu_*/ "$romsPath"/wiiu/tmp/cemu/
	rsync -avzh "$romsPath"/wiiu/tmp/cemu/ "$romsPath"/wiiu/
	rm -rf "$romsPath"/wiiu/tmp 
	rm -f "$romsPath"/wiiu/cemu.zip
	
	if  [ -e "${toolsPath}/launchers/cemu.sh" ]; then #retain launch settings
		local launchLine=$( tail -n 1 "${toolsPath}/launchers/cemu.sh" )
		echo "cemu launch line found: $launchLine"
	fi
	

	cp "$EMUDECKGIT/tools/launchers/cemu.sh" "${toolsPath}/launchers/cemu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|" "${toolsPath}/launchers/cemu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|" "${toolsPath}/launchers/cemu.sh"

	if [[ "$launchLine"  == *"PROTONLAUNCH"* ]]; then
		changeLine '"${PROTONLAUNCH}"' "$launchLine" "${toolsPath}/launchers/cemu.sh"
	fi
	chmod +x "${toolsPath}/launchers/cemu.sh"
	

	createDesktopShortcut   "$HOME/.local/share/applications/Cemu.desktop" \
							"Cemu EmuDeck" \
							"${toolsPath}/launchers/cemu.sh" \
							"False"
	}

#ApplyInitialSettings
Cemu_init(){
	setMSG "Initializing $Cemu_emuName settings."	
	rsync -avhp "$EMUDECKGIT/configs/info.cemu.Cemu/data/cemu/" "${romsPath}/wiiu" --backup --suffix=.bak
	if [ -e "$Cemu_cemuSettings.bak" ]; then
		mv -f "$Cemu_cemuSettings.bak" "$Cemu_cemuSettings" #retain cemuSettings
	fi
    Cemu_setEmulationFolder
	Cemu_setupSaves
	Cemu_addSteamInputProfile

}

#update
Cemu_update(){
	setMSG "Updating $Cemu_emuName settings."	
    rsync -avhp "$EMUDECKGIT/configs/info.cemu.Cemu/data/cemu/" "${romsPath}/wiiu" --ignore-existing
    Cemu_setEmulationFolder
	Cemu_setupSaves
	Cemu_addSteamInputProfile
}


#ConfigurePaths
Cemu_setEmulationFolder(){
	setMSG "Setting $Cemu_emuName Emulation Folder"	
	
	if [[ -f "${Cemu_cemuSettings}" ]]; then
		gamePathEntryFound=$(grep -rnw "$Cemu_cemuSettings" -e "z:${romsPath}/wiiu/roms")
		if [[ $gamePathEntryFound == '' ]]; then 
			xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "z:${romsPath}/wiiu/roms" "$Cemu_cemuSettings"
		fi
	fi
}

#SetupSaves
Cemu_setupSaves(){
	unlink "${savesPath}/Cemu/saves" # Fix for previous bad symlink
	linkToSaveFolder Cemu saves "${romsPath}/wiiu/mlc01/usr/save"
}


#SetupStorage
Cemu_setupStorage(){
	echo "NYI"
}


#WipeSettings
Cemu_wipeSettings(){
		echo "NYI"
   # rm -rf "${romPath}wiiu/"
   # prob not cause roms are here
}


#Uninstall
Cemu_uninstall(){
	setMSG "Uninstalling $Cemu_emuName."
    rm -rf "${Cemu_emuPath}"
}

#setABXYstyle
Cemu_setABXYstyle(){
    	echo "NYI"
}

#Migrate
Cemu_migrate(){
   	echo "NYI" 
}

#WideScreenOn
Cemu_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Cemu_wideScreenOff(){
echo "NYI"
}

#BezelOn
Cemu_bezelOn(){
echo "NYI"
}

#BezelOff
Cemu_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
Cemu_finalize(){
    Cemu_cleanup
}

Cemu_addSteamInputProfile(){
	setMSG "Adding $Cemu_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/cemu_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
