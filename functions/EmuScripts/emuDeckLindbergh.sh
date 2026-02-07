#!/bin/bash
#variables
Lindbergh_emuName="Lindbergh Loader"
Lindbergh_emuType="$emuDeckEmuTypeFlatpak"
Lindbergh_emuPath="com.github.lindberghloader"
Lindbergh_releaseURL=""
Lindbergh_configDir="$HOME/.config/lindbergh-loader"
Lindbergh_configFile="$Lindbergh_configDir/config/lindbergh.ini"

#cleanupOlderThings
Lindbergh_cleanup(){
	echo "NYI"
}

#Install
Lindbergh_install(){
	setMSG "Installing $Lindbergh_emuName"
	local showProgress="$1"

	# Fetch latest .flatpak from GitHub Releases API
	local api_url='https://api.github.com/repos/lindbergh-loader/lindbergh-loader/releases/latest'
	local flatpak_url
	flatpak_url="$(curl -s -H "User-Agent: EmuDeck" "$api_url" \
		| jq -r '.assets[] | select(.name | endswith(".flatpak")) | .browser_download_url' \
		| head -n 1)"

	if [[ -z "$flatpak_url" || "$flatpak_url" == "null" ]]; then
		echo "Error: Could not get latest Lindbergh Loader flatpak URL from GitHub"
		return 1
	fi

	local downloadPath="$HOME/emudeck/lindbergh-loader.flatpak"
	mkdir -p "$HOME/emudeck"

	if safeDownload "$Lindbergh_emuName" "$flatpak_url" "$downloadPath" "$showProgress"; then
		# Install the sideloaded flatpak
		flatpak install --user -y "$downloadPath"

		# Install i386 compatibility layers required for 32-bit Lindbergh binaries
		flatpak install --user -y flathub org.freedesktop.Platform.Compat.i386//24.08 || true
		flatpak install --user -y flathub org.freedesktop.Platform.GL32.default//24.08 || true

		# Allow access to ROM files
		flatpak override --user --filesystem=host "$Lindbergh_emuPath"
		flatpak override --user --share=network "$Lindbergh_emuPath"

		# Cleanup downloaded file
		rm -f "$downloadPath"

		# Remove system-wide install if user install succeeded
		if [ "$(flatpak --columns=app list --user | grep "$Lindbergh_emuPath")" == "$Lindbergh_emuPath" ]; then
			flatpak uninstall "$Lindbergh_emuPath" --system -y 2>/dev/null || true
		fi
	else
		echo "Error: Failed to download Lindbergh Loader flatpak"
		return 1
	fi
}

#ApplyInitialSettings
Lindbergh_init(){
	setMSG "Initializing $Lindbergh_emuName"

	# Create config directories
	mkdir -p "$Lindbergh_configDir/config"
	mkdir -p "$Lindbergh_configDir/controls"

	# Deploy configs with backup
	rsync -avhp --mkpath "$emudeckBackend/configs/lindbergh-loader/config/" "$Lindbergh_configDir/config/" --backup --suffix=.bak
	rsync -avhp --mkpath "$emudeckBackend/configs/lindbergh-loader/controls/" "$Lindbergh_configDir/controls/" --backup --suffix=.bak

	Lindbergh_setupStorage
	Lindbergh_setEmulationFolder
	Lindbergh_setupSaves
	Lindbergh_flushEmulatorLauncher
	Lindbergh_addSteamInputProfile
	Lindbergh_addParser
}

#update
Lindbergh_update(){
	setMSG "Updating $Lindbergh_emuName"

	# Re-install latest version
	Lindbergh_install "$1"

	# Update configs (preserve user changes)
	rsync -avhp --mkpath "$emudeckBackend/configs/lindbergh-loader/config/" "$Lindbergh_configDir/config/" --ignore-existing
	rsync -avhp --mkpath "$emudeckBackend/configs/lindbergh-loader/controls/" "$Lindbergh_configDir/controls/" --ignore-existing

	Lindbergh_setupStorage
	Lindbergh_setEmulationFolder
	Lindbergh_setupSaves
	Lindbergh_flushEmulatorLauncher
	Lindbergh_addSteamInputProfile
}

#ConfigurePaths
Lindbergh_setEmulationFolder(){
	# Create ROM directory
	mkdir -p "$romsPath/lindbergh"
}

#SetupSaves
Lindbergh_setupSaves(){
	# Lindbergh games store saves in their own directories
	# No central save location to configure
	echo "NYI"
}

#SetupStorage
Lindbergh_setupStorage(){
	mkdir -p "$storagePath/lindbergh-loader"
}

#WipeSettings
Lindbergh_wipe(){
	rm -rf "$Lindbergh_configDir"
}

#Uninstall
Lindbergh_uninstall(){
	setMSG "Uninstalling $Lindbergh_emuName"
	removeParser "arcade_lindbergh.json"
	flatpak uninstall "$Lindbergh_emuPath" --user -y 2>/dev/null || true
	flatpak uninstall "$Lindbergh_emuPath" --system -y 2>/dev/null || true
}

#setABXYstyle
Lindbergh_setABXYstyle(){
	echo "NYI"
}

#Migrate
Lindbergh_migrate(){
	echo "NYI"
}

#WideScreenOn
Lindbergh_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Lindbergh_wideScreenOff(){
	echo "NYI"
}

#BezelOn
Lindbergh_bezelOn(){
	echo "NYI"
}

#BezelOff
Lindbergh_bezelOff(){
	echo "NYI"
}

Lindbergh_IsInstalled(){
	isFpInstalled "$Lindbergh_emuPath"
}

Lindbergh_resetConfig(){
	Lindbergh_init &>/dev/null && echo "true" || echo "false"
}

#finalExec - Extra stuff
Lindbergh_finalize(){
	echo "NYI"
}

Lindbergh_flushEmulatorLauncher(){
	flushEmulatorLaunchers "lindbergh"
}

Lindbergh_addSteamInputProfile(){
	setMSG "Adding $Lindbergh_emuName Steam Input Profile."
	rsync -r --exclude='*/' "$emudeckBackend/configs/steam-input/emudeck_steam_deck_light_gun_controls.vdf" "$HOME/.steam/steam/controller_base/templates/emudeck_steam_deck_light_gun_controls.vdf"
}

Lindbergh_addParser(){
	addParser "arcade_lindbergh.json"
}
