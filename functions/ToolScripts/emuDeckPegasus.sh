#!/bin/bash
#variables
Pegasus_toolName="Pegasus Frontend"
Pegasus_emuPath="org.pegasus_frontend.Pegasus"
Pegasus_path="$HOME/.var/app/$Pegasus_emuPath/config"
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

	#metadata and paths
	rsync -r  "$EMUDECKGIT/roms/" "$romsPath"
	rsync -av -f"+ */" -f"- *"  "$EMUDECKGIT/roms/" "$toolsPath/downloaded_media"
	find $romsPath -type f -name "metadata.txt" -exec sed -i "s|CORESPATH|${RetroArch_cores}|g" {} \;
	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$Pegasus_dir_file"
	for systemPath in "$romsPath"/*; do rm -rf "$systemPath/media" &> /dev/null; done
	for systemPath in "$romsPath"/*; do system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/'); ln -s "$toolsPath/downloaded_media/$system" "$systemPath/media" &> /dev/null; done

	#Pegasus_addCustomSystems
	#Pegasus_setEmulationFolder
	#Pegasus_setDefaultEmulators
	Pegasus_applyTheme "$pegasusTheme"

	user=$(zenity --entry --title="ScreenScrapper" --text="User:")
	password=$(zenity --password --title="ScreenScrapper" --text="Password:")

	encryption_key=$(openssl rand -base64 32)
	encrypted_password=$(echo "$password" | openssl enc -aes-256-cbc -pbkdf2 -base64 -pass "pass:$encryption_key")

	echo "$encryption_key" > "$HOME/.config/EmuDeck/logs/.key"
	echo "$encrypted_password" > "$HOME/.config/EmuDeck/.passSS"
	echo "$user" > "$HOME/.config/EmuDeck/.userSS"


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
