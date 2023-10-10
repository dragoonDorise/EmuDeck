#!/bin/bash
#variables
Pegasus_toolName="Pegasus Frontend"
Pegasus_emuPath="org.pegasus_frontend.Pegasus"
Pegasus_path="$HOME/.var/app/$Pegasus_emuPath"
Pegasus_dir_file="$HOME/.var/app/$Pegasus_emuPath/pegasus-frontend/game_dirs.txt"
Pegasus_config_file="$HOME/.var/app/$Pegasus_emuPath/pegasus-frontend/settings.txt"

#cleanupOlderThings
Pegasus_cleanup(){
	echo "NYI"
}

#Install
Pegasus_install(){

	setMSG "Installing $Pegasus_toolName"

	local showProgress="$1"

	installEmuFP "${Pegasus_toolName}" "${Pegasus_emuPath}"
	flatpak override "${Pegasus_emuPath}" --filesystem=host --user
	Pegasus_init

}

#ApplyInitialSettings
Pegasus_init(){
	setMSG "Setting up $Pegasus_toolName"

	rsync -avhp --mkpath "$EMUDECKGIT/configs/$Pegasus_emuPath/" "$Pegasus_path/"

	#metadata and cores paths
	rsync -r  "$EMUDECKGIT/roms/" "$romsPath"
	find $romsPath -type f -name "metadata.txt" -exec sed -i "s|CORESPATH|${RetroArch_cores}|g" {} \;


	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$Pegasus_dir_file"

	#Pegasus_addCustomSystems
	#Pegasus_setEmulationFolder
	#Pegasus_setDefaultEmulators
	Pegasus_applyTheme "$pegasusTheme"
}


Pegasus_resetConfig(){
	Pegasus_init &>/dev/null && echo "true" || echo "false"
}

Pegasus_update(){
	Pegasus_init &>/dev/null && echo "true" || echo "false"
}

Pegasus_addCustomSystems(){
	echo "NYI"
}

Pegasus_applyTheme(){
	pegasusTheme=$1

	local themeName=$(basename "$(echo $pegasusTheme | rev | cut -d'/' -f1 | rev)")
	themeName="${themeName/.git/""}"

	git clone --no-single-branch --depth=1 "$pegasusTheme" "$Pegasus_path/themes/$themeName/"
	cd "$Pegasus_path/themes/$themeName/" && git pull

	changeLine 'general.theme:' 'general.theme: themes/$themeName' "$Pegasus_config_file"

	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$Pegasus_dir_file"
}

Pegasus_setDefaultEmulators(){
	echo "NYI"
}

Pegasus_setEmu(){
	echo "NYI"
}

Pegasus_IsInstalled(){
	isFpInstalled "$Pegasus_emuPath"
}

Pegasus_uninstall(){
	flatpak uninstall "$Pegasus_emuPath" --user -y
}
