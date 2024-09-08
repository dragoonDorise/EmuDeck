#!/bin/bash
#variables
Xenia_emuName="Xenia"
Xenia_emuType="$emuDeckEmuTypeWindows"
Xenia_emuPath="${romsPath}/xbox360/xenia_canary.exe"
Xenia_releaseURL_master="https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip"
Xenia_releaseURL_canary="https://github.com/xenia-canary/xenia-canary/releases/latest/download/xenia_canary.zip"
Xenia_XeniaSettings="${romsPath}/xbox360/xenia-canary.config.toml"

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
	echo $name
	setMSG "Installing Xenia $version"

	#need to look at standardizing exe name; or download both?  let the user choose at runtime?
	#curl -L "$Xenia_releaseURL" --output "$romsPath"/xbox360/xenia.zip
	if safeDownload "$Xenia_emuName" "$Xenia_releaseURL" "$romsPath/xbox360/xenia.zip" "$showProgress"; then
		#mkdir -p "$romsPath"/xbox360/tmp
		unzip -o "$romsPath"/xbox360/xenia.zip -d "$romsPath"/xbox360
		#rsync -avzh "$romsPath"/xbox360/tmp/ "$romsPath"/xbox360/
		#rm -rf "$romsPath"/xbox360/tmp
		rm -f "$romsPath"/xbox360/xenia.zip
		# Prevents it from showing up in ES-DE
		mv -f "$romsPath/xbox360/LICENSE" "$romsPath/xbox360/LICENSE.TXT"
	else
		return 1
	fi

	cp "$EMUDECKGIT/tools/launchers/xenia.sh" "${toolsPath}/launchers/xenia.sh"
	cp "$EMUDECKGIT/tools/launchers/xenia.sh" "$romsPath/emulators/xenia.sh"
	cp "$EMUDECKGIT/tools/launchers/xenia.sh" "$romsPath/xbox360/xenia.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "${toolsPath}/launchers/xenia.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|" "${toolsPath}/launchers/xenia.sh"
	mkdir -p "$romsPath/xbox360/roms/xbla"

#	if [[ "$launchLine"  == *"PROTONLAUNCH"* ]]; then
#		changeLine '"${PROTONLAUNCH}"' "$launchLine" "${toolsPath}/launchers/xenia.sh"
#	fi
	chmod +x "${toolsPath}/launchers/xenia.sh"
	chmod +x "$romsPath/emulators/xenia.sh"
	chmod +x "$romsPath/xbox360/xenia.sh"

	Xenia_getPatches
	Xenia_cleanESDE

	createDesktopShortcut   "$HOME/.local/share/applications/xenia.desktop" \
							"Xenia (Proton)" \
							"${toolsPath}/launchers/xenia.sh" \
							"False"
}

#ApplyInitialSettings
Xenia_init(){
	setMSG "Initializing Xenia Config"
	rsync -avhp "$EMUDECKGIT/configs/xenia/" "$romsPath/xbox360"
	mkdir -p "$romsPath/xbox360/roms/xbla"
	Xenia_setupSaves
	#SRM_createParsers
	Xenia_cleanESDE
	Xenia_flushEmulatorLauncher
	addProtonLaunch
	
	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		Xenia_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi

}

Xenia_addESConfig(){

	ESDE_junksettingsFile
	ESDE_addCustomSystemsFile
	ESDE_setEmulationFolder
	
	if [[ $(grep -rnw "$es_systemsFile" -e 'xbox360') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'xbox360' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Microsoft Xbox 360' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/xbox360/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.iso .ISO . .xex .XEX' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "/bin/bash ${toolsPath}/launchers/xenia.sh z:%ROM% %INJECT%=%BASENAME%.esprefix" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Xenia (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'xbox360' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'xbox360' \
		-r 'systemList/system/commandP' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi
	#Custom Systems config end
}

function Xenia_getPatches() {
	local patches_url="https://github.com/xenia-canary/game-patches/releases/latest/download/game-patches.zip"

	mkdir -p "${romsPath}/xbox360/patches"
	if  [[ ! "$( ls -A "${romsPath}/xbox360/patches")" ]] ; then
		{ curl -L "$patches_url" -o "${romsPath}/xbox360/game-patches.zip" && nice -n 5 unzip -q -o "${romsPath}/xbox360/game-patches.zip" -d "${romsPath}/xbox360" && rm "${romsPath}/xbox360/game-patches.zip"; } &> /dev/null
		echo "Xenia patches downloaded." 
	else 
		{ curl -L "$patches_url" -o "${romsPath}/xbox360/game-patches.zip" && nice -n 5 unzip -uqo "${romsPath}/xbox360/game-patches.zip" -d "${romsPath}/xbox360" && rm "${romsPath}/xbox360/game-patches.zip"; } &> /dev/null
		echo "Xenia patches updated." 
	fi

}


#update
Xenia_update(){
	echo "NYI"
	Xenia_setupSaves
	Xenia_flushEmulatorLauncher
}

#ConfigurePaths
Xenia_setEmulationFolder(){
	echo "NYI"
}

#SetupSaves
Xenia_setupSaves(){
	mkdir -p "$romsPath/xbox360/content"
	linkToSaveFolder xenia saves "$romsPath/xbox360/content"
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
	setMSG "Uninstalling $Xenia_emuName. Saves and ROMs will be retained in the ROMs folder."
	find ${romsPath}/xbox360 -mindepth 1 \( -name roms -o -name content \) -prune -o -exec rm -rf '{}' \; &>> /dev/null
	rm -rf $HOME/.local/share/applications/xenia.desktop &> /dev/null
	rm -rf "${toolsPath}/launchers/xenia.sh"
	rm -rf "$romsPath/emulators/xenia.sh"
	rm -rf "$romsPath/xbox360/xenia.sh"
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

Xenia_setResolution(){
	$xeniaResolution
	echo "NYI"
}

Xenia_cleanESDE(){

	# These files/folders make it so if you have no ROMs in xbox360, it still shows up as an "active" system.

	if [ -d "${romsPath}/xbox360/.git" ]; then
		rm -rf "${romsPath}/xbox360/.git"
	fi

	if [ -f "$romsPath/xbox360/LICENSE" ]; then 
		mv -f "$romsPath/xbox360/LICENSE" "$romsPath/xbox360/LICENSE.TXT"
	fi



}

Xenia_flushEmulatorLauncher(){
	flushEmulatorLaunchers "xenia"
}

