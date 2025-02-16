#!/bin/bash
#variables
pegasus_toolName="Pegasus Frontend"
pegasus_emuPath="pegasus-frontend"
pegasus_path="$HOME/.config/$pegasus_emuPath"
pegasus_dir_file="$pegasus_path/game_dirs.txt"
pegasus_config_file="$pegasus_path/settings.txt"
pegasus_themes_path="$pegasus_path/themes"

#cleanupOlderThings
pegasus_cleanup(){
	echo "NYI"
}

#Install
pegasus_install(){

	setMSG "Installing $pegasus_toolName"
	flatpak uninstall "$pegasus_emuPath" --user -y &> /dev/null;
	local showProgress="$1"
	local name="pegasus-fe"
	local url="https://github.com/dragoonDorise/pegasus-temp/releases/download/1.0/pegasus-fe"
	local fileName="pegasus-fe"

	if safeDownload "$name" "$url" "$pegasusFolder/$fileName" "$showProgress"; then
		chmod +x "$pegasusFolder/$fileName"
		pegasus_init
		pegasus_customDesktopShortcut
	else
		return 1
	fi


}

pegasus_setPaths(){
	rsync -avR --exclude='roms' --exclude='pfx' "$emudeckBackend/roms/" "$romsPath" --keep-dirlinks
	rsync -avR --exclude='roms' --exclude='pfx' "$emudeckBackend/roms/" "$toolsPath/downloaded_media"
	find $romsPath/ -type f -name "metadata.txt" -exec sed -i "s|CORESPATH|${RetroArch_cores}|g" {} \;
	find $romsPath/ -type f -name "metadata.txt" -exec sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" {} \;

	#Alternative emulators

	if [ "$(Flycast_IsInstalled)" == "true" ]; then
		cp "$emudeckBackend/roms_alt_emus/dreamcast/metadata.txt" "$romsPath/n3ds/metadata.txt"
	fi

	if [ "$(mGBA_IsInstalled)" == "true" ]; then
		cp "$emudeckBackend/roms_alt_emus/gba/metadata.txt" "$romsPath/gba/metadata.txt"
	fi

	if [ "$(Lime3DS_IsInstalled)" == "true" ]; then
		cp "$emudeckBackend/roms_alt_emus/n3ds/metadata.txt" "$romsPath/n3ds/metadata.txt"
	fi

	if [ "$(RMG_IsInstalled)" == "true" ]; then
		cp "$emudeckBackend/roms_alt_emus/n64/metadata.txt" "$romsPath/n64/metadata.txt"
	fi

	if [ "$(melonDS_IsInstalled)" == "true" ]; then
		cp "$emudeckBackend/roms_alt_emus/nds/metadata.txt" "$romsPath/nds/metadata.txt"
	fi

	if [ "$(Yuzu_IsInstalled)" == "true" ]; then
		cp "$emudeckBackend/roms_alt_emus/switch/yuzu/metadata.txt" "$romsPath/switch/metadata.txt"
	fi

	if [ "$(Citron_IsInstalled)" == "true" ]; then
		cp "$emudeckBackend/roms_alt_emus/switch/citron/metadata.txt" "$romsPath/switch/metadata.txt"
	fi


}

#ApplyInitialSettings
pegasus_init(){
	setMSG "Setting up $pegasus_toolName"

	rsync -avhp --mkpath "$emudeckBackend/configs/$pegasus_emuPath/" "$pegasus_path/"

	#metadata and paths
		pegasus_setPaths
		pegasus_addToSteam

		if [ -L "$toolsPath/downloaded_media/gamecube" ]; then
			rm -rf "$toolsPath/downloaded_media/gamecube" &> /dev/null
		fi

		if [ -L "$toolsPath/downloaded_media/3ds" ]; then
			rm -rf "$toolsPath/downloaded_media/3ds" &> /dev/null
		fi

		if [ -L "$toolsPath/downloaded_media/cloud" ]; then
			rm -rf "$toolsPath/downloaded_media/cloud" &> /dev/null
		fi

		if [ -L "$toolsPath/downloaded_media/remoteplay" ]; then
			rm -rf "$toolsPath/downloaded_media/remoteplay" &> /dev/null
		fi

		for systemPath in "$romsPath"/*; do
			echo "$romsPath"
			if  [[ "$systemPath" == "$romsPath/model2" || "$systemPath" == "$romsPath/xbox360" || "$systemPath" == "$romsPath/wiiu" ]]; then
				rm -rf "$systemPath/roms/media" &> /dev/null
				rm -rf "$romsPath/xbox360/roms/xbla/media" &> /dev/null
				rm -rf "$romsPath/xbox360/roms/xbla/metadata.txt" &> /dev/null
			elif  [[ "$systemPath" == "$romsPath/3ds" || "$systemPath" == "$romsPath/cloud" || "$systemPath" == "$romsPath/gamecube" || "$systemPath" == "$romsPath/generic-applications" || "$systemPath" == "$romsPath/remoteplay" ]]; then
				continue
			elif  [[ "$systemPath" == "$romsPath/desktop" ]]; then
				rm -rf "$romsPath/desktop/remoteplay/media" &> /dev/null
				rm -rf "$romsPath/desktop/generic-applications/media" &> /dev/null
				rm -rf "$romsPath/desktop/cloud/media" &> /dev/null
				rm -rf "$systemPath/media" &> /dev/null
			else
				rm -rf "$systemPath/media" &> /dev/null
			fi
		done


		for systemPath in "$romsPath"/*; do
			if [[ "$systemPath" == "$romsPath/model2" || "$systemPath" == "$romsPath/xbox360" || "$systemPath" == "$romsPath/wiiu" ]]; then
				system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')
				echo $system
				mkdir -p "$toolsPath/downloaded_media/$system/covers"
				rm -rf "$toolsPath/downloaded_media/$system/box2dfront"
				mkdir -p "$toolsPath/downloaded_media/$system/marquees"
				rm -rf "$toolsPath/downloaded_media/$system/wheel" &> /dev/null
				rm -rf "$toolsPath/downloaded_media/$system/screenshot" &> /dev/null
				mkdir -p "$toolsPath/downloaded_media/$system/screenshots/"
			elif  [[ "$systemPath" == "$romsPath/3ds" || "$systemPath" == "$romsPath/cloud" || "$systemPath" == "$romsPath/gamecube" || "$systemPath" == "$romsPath/generic-applications" || "$systemPath" == "$romsPath/remoteplay" ]]; then
				continue
			elif [[ "$systemPath" == "$romsPath/desktop" ]]; then
				system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')
				echo $system
				mkdir -p "$toolsPath/downloaded_media/$system/covers"
				rm -rf "$toolsPath/downloaded_media/$system/box2dfront"
				mkdir -p "$toolsPath/downloaded_media/$system/marquees"
				rm -rf "$toolsPath/downloaded_media/$system/wheel" &> /dev/null
				rm -rf "$toolsPath/downloaded_media/$system/screenshot" &> /dev/null
				mkdir -p "$toolsPath/downloaded_media/$system/screenshots/"
			else
				system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')
				mkdir -p "$toolsPath/downloaded_media/$system/covers"
				rm -rf "$toolsPath/downloaded_media/$system/box2dfront"
				mkdir -p "$toolsPath/downloaded_media/$system/marquees"
				rm -rf "$toolsPath/downloaded_media/$system/wheel" &> /dev/null
				rm -rf "$toolsPath/downloaded_media/$system/screenshot" &> /dev/null
				mkdir -p "$toolsPath/downloaded_media/$system/screenshots/"
			fi
		done


		for systemPath in "$romsPath"/*; do
			if  [[ "$systemPath" == "$romsPath/model2" || "$systemPath" == "$romsPath/xbox360" || "$systemPath" == "$romsPath/wiiu" ]]; then
				system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')
				ln -s "$toolsPath/downloaded_media/$system" "$systemPath/roms/media" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/covers/" "$toolsPath/downloaded_media/$system/box2dfront" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/marquees/" "$toolsPath/downloaded_media/$system/wheel" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/screenshots/" "$toolsPath/downloaded_media/$system/screenshot" &> /dev/null
			elif  [[ "$systemPath" == "$romsPath/3ds" || "$systemPath" == "$romsPath/cloud" || "$systemPath" == "$romsPath/gamecube" || "$systemPath" == "$romsPath/generic-applications" || "$systemPath" == "$romsPath/remoteplay" ]]; then
				continue
			elif [[ "$systemPath" == "$romsPath/desktop" ]]; then
				system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')
				mkdir -p "$romsPath/desktop/cloud"
				mkdir -p "$romsPath/desktop/generic-applications"
				mkdir -p "$romsPath/desktop/remoteplay"
				ln -s "$toolsPath/downloaded_media/$system" "$systemPath/media" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system" "$systemPath/cloud/media" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system" "$systemPath/remoteplay/media" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system" "$systemPath/generic-applications/media" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/covers/" "$toolsPath/downloaded_media/$system/box2dfront" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/marquees/" "$toolsPath/downloaded_media/$system/wheel" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/screenshots/" "$toolsPath/downloaded_media/$system/screenshot" &> /dev/null
			else
				system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')
				ln -s "$toolsPath/downloaded_media/$system" "$systemPath/media" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/covers/" "$toolsPath/downloaded_media/$system/box2dfront" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/marquees/" "$toolsPath/downloaded_media/$system/wheel" &> /dev/null
				ln -s "$toolsPath/downloaded_media/$system/screenshots/" "$toolsPath/downloaded_media/$system/screenshot" &> /dev/null
			fi
		done

		for systemPath in "$romsPath"/*; do
			rm -rf ".*/" &> /dev/null;
		done




	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$pegasus_dir_file"
	#mkdir -p "$toolsPath/launchers/pegasus/"
	#cp "$emudeckBackend/tools/launchers/pegasus/pegasus-frontend.sh" "$toolsPath/launchers/pegasus/pegasus-frontend.sh"
	#pegasus_addCustomSystems
	#pegasus_setEmulationFolder
	#pegasus_setDefaultEmulators
	pegasus_applyTheme "$pegasusThemeUrl"
	addSteamInputCustomIcons
	pegasus_flushToolLauncher
	SRM_flushOldSymlinks

}

Pegasus_resetConfig(){
	pegasus_resetConfig
}
pegasus_resetConfig(){
	pegasus_init &>/dev/null && echo "true" || echo "false"
}

pegasus_update(){
	pegasus_init &>/dev/null && echo "true" || echo "false"
}

pegasus_addCustomSystems(){
	echo "NYI"
}

pegasus_applyTheme(){
	pegasusTheme=$1

	local themeName=$(basename "$(echo $pegasusTheme | rev | cut -d'/' -f1 | rev)")
	themeName="${themeName/.git/""}"

	git clone --no-single-branch --depth=1 "$pegasusTheme" "$pegasus_themes_path/$themeName/"
	cd "$pegasus_path/themes/$themeName/" && git pull

	changeLine 'general.theme:' "general.theme: themes/$themeName" "$pegasus_config_file"

}

pegasus_customDesktopShortcut(){

    createDesktopShortcut   "$HOME/.local/share/applications/Pegasus.desktop" \
        "Pegasus Binary" \
        "${toolsPath}/launchers/pegasus/pegasus-frontend.sh" \
        "false"
}

pegasus_setDefaultEmulators(){
	echo "NYI"
}

pegasus_setEmu(){
	echo "NYI"
}

pegasus_IsInstalled(){
  if [ -f  "$pegasusFolder/pegasus-fe" ]; then
  	echo "true"
  else
 	 echo "false"
  fi
}

pegasus_uninstall(){
	flatpak uninstall "$pegasus_emuPath" --user -y &> /dev/null;
	rm -rf "$pegasusFolder/pegasus-fe" &> /dev/null;
}

pegasus_flushToolLauncher(){
	mkdir -p "$toolsPath/launchers/pegasus/"
	cp "$emudeckBackend/tools/launchers/pegasus/pegasus-frontend.sh" "$toolsPath/launchers/pegasus/pegasus-frontend.sh"
	chmod +x "$toolsPath/launchers/pegasus/pegasus-frontend.sh"
}


pegasus_addToSteam(){
	setMSG "Adding $pegasus_toolName to Steam"
	add_to_steam "pegasus" "$pegasus_toolName" "$toolsPath/launchers/pegasus/pegasus-frontend.sh" "$HOME/Applications/" "$HOME/.config/EmuDeck/backend/icons/ico/pegasus.ico"
}