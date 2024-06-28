#!/bin/bash
#variables
CemuProton_emuName="Cemu (proton)"
CemuProton_emuType="$emuDeckEmuTypeWindows"
CemuProton_emuPath="${romsPath}/wiiu/Cemu.exe"
CemuProton_cemuSettings="${romsPath}/wiiu/settings.xml"

# https://github.com/cemu-project/Cemu/blob/main/src/config/CemuConfig.h#L158-L172
declare -A CemuProton_languages
CemuProton_languages=(
["ja"]=0
["en"]=1
["fr"]=2
["de"]=3
["it"]=4
["es"]=5
["zh"]=6
["ko"]=7
["nl"]=8
["pt"]=9
["ru"]=10
["tw"]=11)

#cleanupOlderThings
CemuProton_cleanup(){
	echo "NYI"
}

#Install
CemuProton_install(){
	setMSG "Installing $CemuProton_emuName"

	local showProgress="$1"
	CemuProton_releaseURL="$(getReleaseURLGH "cemu-project/Cemu" "windows-x64.zip")"
	#curl $CemuProton_releaseURL --output "$romsPath"/wiiu/cemu.zip
	if safeDownload "cemu" "$CemuProton_releaseURL" "$romsPath/wiiu/cemu.zip" "$showProgress"; then
		mkdir -p "$romsPath/wiiu/tmp"
		unzip -o "$romsPath/wiiu/cemu.zip" -d "$romsPath/wiiu/tmp"
		mv "$romsPath"/wiiu/tmp/[Cc]emu_*/ "$romsPath/wiiu/tmp/cemu/" #don't quote the *
		rsync -avzh "$romsPath/wiiu/tmp/cemu/" "$romsPath/wiiu/"
		rm -rf "$romsPath/wiiu/tmp"
		rm -f "$romsPath/wiiu/cemu.zip"
	else
		return 1
	fi


#	if  [ -e "${toolsPath}/launchers/cemu.sh" ]; then #retain launch settings
#		local launchLine=$( tail -n 1 "${toolsPath}/launchers/cemu.sh" )
#		echo "cemu launch line found: $launchLine"
#	fi


	cp "$EMUDECKGIT/tools/launchers/cemu.sh" "${toolsPath}/launchers/cemu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "${toolsPath}/launchers/cemu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|" "${toolsPath}/launchers/cemu.sh"

#	if [[ "$launchLine"  == *"PROTONLAUNCH"* ]]; then
#		changeLine '"${PROTONLAUNCH}"' "$launchLine" "${toolsPath}/launchers/cemu.sh"
#	fi
	chmod +x "${toolsPath}/launchers/cemu.sh"


	createDesktopShortcut   "$HOME/.local/share/applications/Cemu (Proton).desktop" \
							"Cemu (Proton)" \
							"${toolsPath}/launchers/cemu.sh -w"  \
							"False"
	}

#ApplyInitialSettings
CemuProton_init(){
	setMSG "Initializing $CemuProton_emuName settings."
	rsync -avhp "$EMUDECKGIT/configs/info.cemu.Cemu/data/cemu/" "${romsPath}/wiiu" --backup --suffix=.bak
	if [ -e "$CemuProton_cemuSettings.bak" ]; then
		mv -f "$CemuProton_cemuSettings.bak" "$CemuProton_cemuSettings" #retain cemuSettings
	fi
	CemuProton_setEmulationFolder
	CemuProton_setupSaves
	#SRM_createParsers
	#CemuProton_addSteamInputProfile
	CemuProton_addESConfig
	CemuProton_flushEmulatorLauncher
	addProtonLaunch

	if [ -e "${romsPath}/wiiu/controllerProfiles/controller1.xml" ];then
		mv "${romsPath}/wiiu/controllerProfiles/controller1.xml" "${romsPath}/wiiu/controllerProfiles/controller1.xml.bak"
	fi
	if [ -e "${romsPath}/wiiu/controllerProfiles/controller2.xml" ];then
		mv "${romsPath}/wiiu/controllerProfiles/controller2.xml" "${romsPath}/wiiu/controllerProfiles/controller2.xml.bak"
	fi
	if [ -e "${romsPath}/wiiu/controllerProfiles/controller3.xml" ];then
		mv "${romsPath}/wiiu/controllerProfiles/controller3.xml" "${romsPath}/wiiu/controllerProfiles/controller3.xml.bak"
	fi

	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		CemuProton_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi
}

#update
CemuProton_update(){
	setMSG "Updating $CemuProton_emuName settings."
	rsync -avhp "$EMUDECKGIT/configs/info.cemu.Cemu/data/cemu/" "${romsPath}/wiiu" --ignore-existing
	CemuProton_setEmulationFolder
	CemuProton_setupSaves
	#CemuProton_addSteamInputProfile
	CemuProton_addESConfig
	CemuProton_flushEmulatorLauncher
	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		CemuProton_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi
}


#ConfigurePaths
CemuProton_setEmulationFolder(){
	setMSG "Setting $CemuProton_emuName Emulation Folder"

	if [[ -f "${CemuProton_cemuSettings}" ]]; then
	#Correct Folder seperators to windows based ones
		#WindowsRomPath=${echo "z:${romsPath}/wiiu/roms" | sed 's/\//\\/g'}
		#gamePathEntryFound=$(grep -rnw "$CemuProton_cemuSettings" -e "${WindowsRomPath}")
		gamePathEntryFound=$(grep -rnw "$CemuProton_cemuSettings" -e "z:${romsPath}/wiiu/roms")
		if [[ $gamePathEntryFound == '' ]]; then
			#xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "${WindowsRomPath}" "$CemuProton_cemuSettings"
			xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "z:${romsPath}/wiiu/roms" "$CemuProton_cemuSettings"
		fi
	fi
}

#SetLanguage
CemuProton_setLanguage(){
	setMSG "Setting $CemuProton_emuName Language"
	local language=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)
	#TODO: call this somewhere, and input the $language from somewhere (args?)
	if [[ -f "${CemuProton_cemuSettings}" ]]; then
		if [ ${CemuProton_languages[$language]+_} ]; then
			xmlstarlet ed --inplace  --subnode "content" --type elem -n "console_language" -v "${CemuProton_languages[$language]}" "$CemuProton_cemuSettings"
		fi
	fi
}

CemuProton_addESConfig(){

	ESDE_junksettingsFile
	ESDE_addCustomSystemsFile
	ESDE_setEmulationFolder

	#insert cemu custom system if it doesn't exist, but the file does
	if [[ $(grep -rnw "$es_systemsFile" -e 'wiiu') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'wiiu' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Nintendo Wii U' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/wiiu/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.elf .ELF .rpx .RPX .tmd .TMD .wua .WUA .wud .WUD .wuhb .WUHB .wux .WUX' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "/bin/bash ${toolsPath}/launchers/cemu.sh -f -g z:%ROM%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Cemu (Native)" \
		--subnode '$newSystem' --type elem --name 'commandN' -v "/bin/bash ${toolsPath}/launchers/cemu.sh -w -f -g %ROM%" \
		--insert '$newSystem/commandN' --type attr --name 'label' --value "Cemu (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'wiiu' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'wiiu' \
		-r 'systemList/system/commandP' -v 'command' \
		-r 'systemList/system/commandN' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi
    #Custom Systems config end
}

#SetupSaves
CemuProton_setupSaves(){
	unlink "${savesPath}/Cemu/saves" # Fix for previous bad symlink
	linkToSaveFolder Cemu saves "${romsPath}/wiiu/mlc01/usr/save"
}


#SetupStorage
CemuProton_setupStorage(){
	echo "NYI"
}


#WipeSettings
CemuProton_wipeSettings(){
	echo "NYI"
	#rm -rf "${romPath}wiiu/"
	# prob not cause roms are here
}


#Uninstall
CemuProton_uninstall(){
	setMSG "Uninstalling $CemuProton_emuName."
	find ${romsPath}/wiiu -mindepth 1 \( -name roms -o -name mlc01 \) -prune -o -exec rm -rf '{}' \; &>> /dev/null
	rm -f "$HOME/.local/share/applications/Cemu (Proton).desktop" &> /dev/null
}

#setABXYstyle
CemuProton_setABXYstyle(){
		echo "NYI"
}

#Migrate
CemuProton_migrate(){
	   echo "NYI"
}

#WideScreenOn
CemuProton_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
CemuProton_wideScreenOff(){
echo "NYI"
}

#BezelOn
CemuProton_bezelOn(){
echo "NYI"
}

#BezelOff
CemuProton_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
CemuProton_finalize(){
	CemuProton_cleanup
}

CemuProton_IsInstalled(){
	if [ -e "$CemuProton_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

CemuProton_resetConfig(){
	mv  "$CemuProton_cemuSettings" "$CemuProton_cemuSettings.bak" &>/dev/null
	CemuProton_init &>/dev/null && echo "true" || echo "false"
}

CemuProton_addSteamInputProfile(){
	addSteamInputCustomIcons
	#setMSG "Adding $CemuProton_emuName Steam Input Profile."
	#rsync -r "$EMUDECKGIT/configs/steam-input/CemuProton_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

CemuProton_setResolution(){
	echo "NYI"
}

CemuProton_flushEmulatorLauncher(){
	flushEmulatorLaunchers "cemu"
}

