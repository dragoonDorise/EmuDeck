#!/bin/bash
#variables
Model2_emuName="Model-2-Emulator"
Model2_emuType="$emuDeckEmuTypeWindows"
Model2_emuPath="${romsPath}/model2/emulator_multicpu.exe"
Model2_configFile="${romsPath}/model2/EMULATOR.INI"

#cleanupOlderThings
Model2_cleanup(){
	echo "NYI"
}

#Install
Model2_install(){
	setMSG "Installing $Model2_emuName"

	# Create the ROMs and pfx directory if they do not exist
	mkdir -p "$romsPath/model2/roms"

	if safeDownload "Model2" "https://github.com/SeongGino/edc-repo0004/raw/master/m2emulator/1.1c.7z" "$romsPath/model2/Model2.7z" "$showProgress"; then

		7za e -y "$romsPath/model2/Model2.7z" -o"$romsPath/model2"
		rm -f "$romsPath/model2/Model2.7z"

	else
		return 1
	fi

	cp "$emudeckBackend/tools/launchers/model-2-emulator.sh" "$toolsPath/launchers/model-2-emulator.sh"
	cp "$emudeckBackend/tools/launchers/model-2-emulator.sh" "$romsPath/model2/model-2-emulator.sh"
	cp "$emudeckBackend/tools/launchers/model-2-emulator.sh" "$romsPath/emulators/model-2-emulator.sh"

	chmod +x "$toolsPath/launchers/model-2-emulator.sh"
	chmod +x "$romsPath/emulators/model-2-emulator.sh"
	chmod +x "$romsPath/model2/model-2-emulator.sh"

  	createDesktopShortcut   "$HOME/.local/share/applications/Model 2 Emulator (Proton).desktop" \
							"$Model2_emuName (Proton)" \
							"${toolsPath}/launchers/model-2-emulator.sh"  \
							"False"


}

#ApplyInitialSettings
Model2_init(){
	setMSG "Initializing $Model2_emuName settings."
	rsync -avhp "$emudeckBackend/configs/model2/" "${romsPath}/model2" --backup --suffix=.bak
	#SRM_createParsers
	Model2_flushEmulatorLauncher
	Model2_addSteamInputProfile
	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		Model2_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi
}



Model2_addESConfig(){
	
	ESDE_junksettingsFile
	ESDE_addCustomSystemsFile
	ESDE_setEmulationFolder

	if [[ $(grep -rnw "$es_systemsFile" -e 'model2') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'model2' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Sega Model 2' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/model2/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.zip .ZIP' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "/usr/bin/bash ${toolsPath}/launchers/model-2-emulator.sh %BASENAME%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Model 2 Emulator (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'arcade' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'model2' \
		-r 'systemList/system/commandP' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
		echo "Model 2 added to EmulationStation-DE custom_systems"
	fi
}

#update
Model2_update(){
	setMSG "Updating $Model2_emuName settings."
	rsync -avhp "$emudeckBackend/configs/model2/" "${romsPath}/model2" --ignore-existing
	Model2_flushEmulatorLauncher
	Model2_addSteamInputProfile
}


#ConfigurePaths
Model2_setEmulationFolder(){
	setMSG "Setting $Model2_emuName Emulation Folder"

	echo "NYI"
}

#WipeSettings
Model2_wipeSettings(){
	rm -rf $Model2_Settings
}


#Uninstall
Model2_uninstall(){
	setMSG "Uninstalling $Model2_emuName. Saves and ROMs will be retained in the ROMs folder."
	find ${romsPath}/model2 -mindepth 1 -name roms -prune -o -exec rm -rf '{}' \; &>> /dev/null
    rm -rf "$HOME/.local/share/applications/Model 2 Emulator (Proton).desktop" &>> /dev/null
	rm -rf "${toolsPath}/launchers/model-2-emulator.sh"
	rm -rf "$romsPath/emulators/model-2-emulator.sh"
	rm -rf "$romsPath/model2/model-2-emulator.sh"
    Model2_wipeSettings
}

#setABXYstyle
Model2_setABXYstyle(){
		echo "NYI"
}

#finalExec - Extra stuff
Model2_finalize(){
	Model2_cleanup
}

Model2_IsInstalled(){
	if [ -e "$Model2_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Model2_resetConfig(){
	mv  "$Model2_configFile" "$Model2_configFile.bak" &>/dev/null
	Model2_init &>/dev/null && echo "true" || echo "false"
}

Model2_flushEmulatorLauncher(){
	flushEmulatorLaunchers "model-2-emulator"
}

Model2_addSteamInputProfile(){
	setMSG "Adding $Model2_emuName Steam Input Profile."
	rsync -r --exclude='*/' "$emudeckBackend/configs/steam-input/emudeck_steam_deck_light_gun_controls.vdf" "$HOME/.steam/steam/controller_base/templates/emudeck_steam_deck_light_gun_controls.vdf"
}
