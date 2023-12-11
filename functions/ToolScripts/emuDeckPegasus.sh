#!/bin/bash
#variables
pegasus_toolName="Pegasus Frontend"
pegasus_emuPath="org.pegasus_frontend.Pegasus"
pegasus_path="$HOME/.var/app/$pegasus_emuPath/config"
pegasus_dir_file="$pegasus_path/pegasus-frontend/game_dirs.txt"
pegasus_config_file="$pegasus_path/pegasus-frontend/settings.txt"
pegasus_themes_path="$pegasus_path/pegasus-frontend/themes"

#cleanupOlderThings
pegasus_cleanup(){
	echo "NYI"
}

#Install
pegasus_install(){

	setMSG "Installing $pegasus_toolName"

	local showProgress="$1"

	installEmuFP "${pegasus_toolName}" "${pegasus_emuPath}"
	flatpak override "${pegasus_emuPath}" --filesystem=host --user
	pegasus_init

}

#ApplyInitialSettings
pegasus_init(){
	setMSG "Setting up $pegasus_toolName"

	rsync -avhp --mkpath "$EMUDECKGIT/configs/$pegasus_emuPath/" "$pegasus_path/"

	#metadata and paths
	rsync -r  "$EMUDECKGIT/roms/" "$romsPath"
	rsync -av -f"+ */" -f"- *"  "$EMUDECKGIT/roms/" "$toolsPath/downloaded_media"
	find $romsPath -type f -name "metadata.txt" -exec sed -i "s|CORESPATH|${RetroArch_cores}|g" {} \;
	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$pegasus_dir_file"
	for systemPath in "$romsPath"/*; do rm -rf "$systemPath/media" &> /dev/null; done

	for systemPath in "$romsPath"/*; do system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/'); mkdir -p "$toolsPath/downloaded_media/$system/covers"; mkdir -p "$toolsPath/downloaded_media/$system/box2dfront" ; mkdir -p "$toolsPath/downloaded_media/$system/marquees"; mkdir -p "$toolsPath/downloaded_media/$system/wheel" &> /dev/null; done

	for systemPath in "$romsPath"/*; do system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/'); ln -s "$toolsPath/downloaded_media/$system" "$systemPath/media" &> /dev/null; ln -s "$toolsPath/downloaded_media/$system/covers" "$toolsPath/downloaded_media/$system/box2dfront" &> /dev/null; ln -s "$toolsPath/downloaded_media/$system/marquees" "$toolsPath/downloaded_media/$system/wheel" &> /dev/null; done

	for systemPath in "$romsPath"/*; do rm -rf ".*/" &> /dev/null; done

	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$pegasus_dir_file"

	#pegasus_addCustomSystems
	#pegasus_setEmulationFolder
	#pegasus_setDefaultEmulators
	pegasus_applyTheme "$pegasusThemeUrl"

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

pegasus_setDefaultEmulators(){
	echo "NYI"
}

pegasus_setEmu(){
	echo "NYI"
}

pegasus_IsInstalled(){
	isFpInstalled "$pegasus_emuPath"
}

pegasus_uninstall(){
	flatpak uninstall "$pegasus_emuPath" --user -y
}
