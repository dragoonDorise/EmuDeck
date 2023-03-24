#!/bin/bash
#variables
Xenia_emuName="Xenia"
Xenia_emuType="windows"
Xenia_emuPath="${romsPath}/xbox360/xenia_canary.exe"
Xenia_releaseURL_master="https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip"
Xenia_releaseURL_canary="https://github.com/xenia-canary/xenia-canary/releases/latest/download/xenia_canary.zip"
Xenia_XeniaSettings="${romsPath}/xbox360/settings.xml"

#cleanupOlderThings
Xenia_cleanup(){
	echo "NYI"
}

#Install
Xenia_install(){
	local version
	version=$1
	local showProgress="$2"

	if [[ "$version" == "master" ]]; then
		Xenia_releaseURL="$Xenia_releaseURL_master"
	else
		Xenia_releaseURL="$Xenia_releaseURL_canary"
	fi
	local name="$Xenia_emuName-$version"

	setMSG "Installing Xenia $version"		

	#need to look at standardizing exe name; or download both?  let the user choose at runtime?
	#curl -L "$Xenia_releaseURL" --output "$romsPath"/xbox360/xenia.zip
	if safeDownload "$name" "$Xenia_releaseURL" "$romsPath/xbox360/xenia.zip" "$showProgress"; then
		mkdir -p "$romsPath"/xbox360/tmp
		unzip -o "$romsPath"/xbox360/xenia.zip -d "$romsPath"/xbox360/tmp
		rsync -avzh "$romsPath"/xbox360/tmp/ "$romsPath"/xbox360/
		rm -rf "$romsPath"/xbox360/tmp
		rm -f "$romsPath"/xbox360/xenia.zip
	else
		return 1
	fi

	cp "$EMUDECKGIT/tools/launchers/xenia.sh" "${toolsPath}/launchers/xenia.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "${toolsPath}/launchers/xenia.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|" "${toolsPath}/launchers/xenia.sh"

#	if [[ "$launchLine"  == *"PROTONLAUNCH"* ]]; then
#		changeLine '"${PROTONLAUNCH}"' "$launchLine" "${toolsPath}/launchers/xenia.sh"
#	fi
	chmod +x "${toolsPath}/launchers/xenia.sh"	

	createDesktopShortcut   "$HOME/.local/share/applications/xenia.desktop" \
							"Xenia (Proton)" \
							"${toolsPath}/launchers/xenia.sh" \
							"False"
}

#ApplyInitialSettings
Xenia_init(){
	setMSG "Initializing Xenia Config"
	rsync -avhp "$EMUDECKGIT"/configs/xenia/ "$romsPath"/xbox360
}

Xenia_resetConfig(){
	rsync -avhp "$EMUDECKGIT"/configs/xenia/ "$romsPath"/xbox360
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

Xenia_IsInstalled(){
	if [ -e "$Xenia_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Xenia_resetConfig(){
	mv  "$Xenia_XeniaSettings" "$Xenia_XeniaSettings.bak" &>/dev/null
	Xenia_init &>/dev/null && echo "true" || echo "false"
}