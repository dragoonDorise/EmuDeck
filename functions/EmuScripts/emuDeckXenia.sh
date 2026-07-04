#!/bin/bash
#variables
Xenia_emuName="Xenia"
Xenia_emuType="${emuDeckEmuTypeAppImage:-AppImage}"

Xenia_appImageName="xenia_canary_linux.AppImage"
Xenia_applicationsPath="${applicationsPath:-$HOME/Applications}"
Xenia_emuPath="${Xenia_applicationsPath}/${Xenia_appImageName}"
Xenia_releaseRepository="xenia-canary/xenia-canary"

Xenia_dataPath="$HOME/.local/share/Xenia"
Xenia_contentPath="${Xenia_dataPath}/content"
Xenia_patchesPath="${Xenia_dataPath}/patches"
Xenia_legacyPath="${romsPath}/xbox360"

Xenia_XeniaSettings="${Xenia_dataPath}/xenia-canary.config.toml"

#cleanupOlderThings
Xenia_cleanup(){
	echo "NYI"
}

Xenia_installLauncher(){
	local launcherSource="$emudeckBackend/tools/launchers/xenia.sh"
	local launcherTargets=(
		"${toolsPath}/launchers/xenia.sh"
		"$romsPath/emulators/xenia.sh"
	)

	mkdir -p "${toolsPath}/launchers"
	mkdir -p "$romsPath/emulators"

	for launcherTarget in "${launcherTargets[@]}"; do
		cp "$launcherSource" "$launcherTarget"
		chmod +x "$launcherTarget"
	done

	rm -f "$romsPath/xbox360/xenia.sh"
}

#Install
Xenia_install(){
	local version
	version=$1
	local showProgress="$2"
	local latestReleaseURL
	local shouldResetAfterInstall="false"

	setMSG "Installing Xenia Canary"

	mkdir -p "$Xenia_applicationsPath"
	mkdir -p "$romsPath/xbox360"

	if [ ! -e "$Xenia_emuPath" ]; then
		shouldResetAfterInstall="true"
	fi

	latestReleaseURL=$(getLatestReleaseURLGH "$Xenia_releaseRepository" ".AppImage" "linux" "xenia_canary")

	if [[ -z "$latestReleaseURL" ]]; then
		echo "Could not find latest Xenia Canary Linux AppImage release."
		return 1
	fi

	echo "Downloading Xenia Canary from: $latestReleaseURL"

	if safeDownload "$Xenia_emuName" "$latestReleaseURL" "$Xenia_emuPath" "$showProgress"; then
		chmod +x "$Xenia_emuPath"
	else
		return 1
	fi

	Xenia_installLauncher

	rm -f "$HOME/.local/share/applications/xenia.desktop"

	createDesktopShortcut   "$HOME/.local/share/applications/xenia.desktop" \
							"Xenia" \
							"${toolsPath}/launchers/xenia.sh" \
							"False"

	if [ "$shouldResetAfterInstall" == "true" ]; then
		echo "Xenia native AppImage was not previously installed. Running initial reset/config migration."
		Xenia_resetConfig
		Xenia_cleanLegacyProtonInstall
	else
		Xenia_flushEmulatorLauncher
		Xenia_addESConfig
	fi
}

#ApplyInitialSettings
Xenia_init(){
	setMSG "Initializing Xenia Config"

	mkdir -p "$Xenia_dataPath"
	mkdir -p "$romsPath/xbox360/roms/xbla"

	Xenia_migrateLegacyData

	if [ ! -f "$Xenia_dataPath/xenia-canary.config.toml" ]; then
		cp "$emudeckBackend/configs/xenia/xenia-canary.config.toml" "$Xenia_dataPath/xenia-canary.config.toml"
	fi

	Xenia_setNativeConfigDefaults
	Xenia_setupSaves
	Xenia_getPatches
	Xenia_cleanESDE
	Xenia_flushEmulatorLauncher
	Xenia_addESConfig
}

Xenia_setNativeConfigDefaults(){
	if [ -f "$Xenia_XeniaSettings" ]; then
		sed -i 's|^gpu = .*|gpu = "vulkan"|' "$Xenia_XeniaSettings"
		sed -i 's|^fullscreen = .*|fullscreen = true|' "$Xenia_XeniaSettings"
	fi
}

Xenia_migrateLegacyData(){
	mkdir -p "$Xenia_dataPath"

	if [ -f "$Xenia_legacyPath/xenia.config.toml" ] && [ ! -f "$Xenia_dataPath/xenia.config.toml.legacy-backup" ]; then
		cp "$Xenia_legacyPath/xenia.config.toml" "$Xenia_dataPath/xenia.config.toml.legacy-backup"
	fi

	if [ -f "$Xenia_legacyPath/xenia-canary.config.toml" ] && [ ! -f "$Xenia_dataPath/xenia-canary.config.toml.legacy-backup" ]; then
		cp "$Xenia_legacyPath/xenia-canary.config.toml" "$Xenia_dataPath/xenia-canary.config.toml.legacy-backup"
	fi

	if [ -d "$Xenia_legacyPath/patches" ]; then
		mkdir -p "$Xenia_patchesPath"
		rsync -a --ignore-existing "$Xenia_legacyPath/patches/" "$Xenia_patchesPath/" &> /dev/null
	fi
	
	#SRM parsers
	old_path="Z:$romsPath"
	new_path=$romsPath
	find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vdf" -exec sed -i "s|${old_path}|${new_path}|g" {} +
	SRM_addExtraParsers
}

Xenia_migrateLegacySaves(){
	local legacyContentPath="$romsPath/xbox360/content"

	if [ -d "$legacyContentPath" ]; then
		mkdir -p "$Xenia_contentPath"
		rsync -a --ignore-existing "$legacyContentPath/" "$Xenia_contentPath/" &> /dev/null
	fi

	if [ -L "$savesPath/xenia/saves" ]; then
		local currentTarget
		currentTarget="$(readlink "$savesPath/xenia/saves")"

		if [ "$currentTarget" = "$legacyContentPath" ]; then
			unlink "$savesPath/xenia/saves"
		fi
	fi
}

Xenia_addESConfig(){
	[ -f "$es_systemsFile" ] || return 0
	[ -f "$es_rulesFile" ] || return 0

	sed -i '/<name>xbox360<\/name>/,/<\/system>/ {
		/<command label="Xenia">/d
		/<command label="Xenia (Proton)">/d
	}' "$es_systemsFile"

	sed -i '/<name>xbox360<\/name>/,/<\/system>/ {
		/<extension>/a\
	<command label="Xenia">%EMULATOR_XENIA% %ROM%</command>
	}' "$es_systemsFile"

	sed -i '/<emulator name="XENIA">/,/<\/emulator>/d' "$es_rulesFile"

	sed -i "/<\/ruleList>/i\\
    <emulator name=\"XENIA\">\\
        <rule type=\"staticpath\">\\
            <entry>${toolsPath}/launchers/xenia.sh</entry>\\
        </rule>\\
    </emulator>
	" "$es_rulesFile"
}

Xenia_getPatches() {
	local patches_url="https://github.com/xenia-canary/game-patches/releases/latest/download/game-patches.zip"

	mkdir -p "$Xenia_patchesPath"

	if [[ ! "$(ls -A "$Xenia_patchesPath")" ]]; then
		{ curl -L "$patches_url" -o "$Xenia_dataPath/game-patches.zip" && nice -n 5 unzip -q -o "$Xenia_dataPath/game-patches.zip" -d "$Xenia_dataPath" && rm "$Xenia_dataPath/game-patches.zip"; } &> /dev/null
		echo "Xenia patches downloaded."
	else
		{ curl -L "$patches_url" -o "$Xenia_dataPath/game-patches.zip" && nice -n 5 unzip -uqo "$Xenia_dataPath/game-patches.zip" -d "$Xenia_dataPath" && rm "$Xenia_dataPath/game-patches.zip"; } &> /dev/null
		echo "Xenia patches updated."
	fi
}

Xenia_cleanLegacyProtonInstall(){
	setMSG "Cleaning old Xenia Proton files"

	if [ -d "$Xenia_legacyPath" ]; then
		find "$Xenia_legacyPath" -mindepth 1 \( -name roms -o -name content \) -prune -o -exec rm -rf '{}' \; &> /dev/null
	fi

	rm -f "$romsPath/xbox360/xenia.sh" &> /dev/null
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
	mkdir -p "$Xenia_contentPath"
	Xenia_migrateLegacySaves
	linkToSaveFolder xenia saves "$Xenia_contentPath"
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
	setMSG "Uninstalling $Xenia_emuName. Saves and ROMs will be retained."

	rm -f "$Xenia_emuPath" &> /dev/null
	rm -f "$HOME/.local/share/applications/xenia.desktop" &> /dev/null
	rm -f "${toolsPath}/launchers/xenia.sh" &> /dev/null
	rm -f "$romsPath/emulators/xenia.sh" &> /dev/null
	rm -f "$romsPath/xbox360/xenia.sh" &> /dev/null

	find "$romsPath/xbox360" -mindepth 1 \( -name roms -o -name content \) -prune -o -exec rm -rf '{}' \; &> /dev/null

	if [ -d "$Xenia_dataPath" ]; then
		find "$Xenia_dataPath" -mindepth 1 \( -name content \) -prune -o -exec rm -rf '{}' \; &> /dev/null
	fi
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
	mv "$Xenia_XeniaSettings" "$Xenia_XeniaSettings.bak" &> /dev/null
	Xenia_init &> /dev/null && echo "true" || echo "false"
}

Xenia_setResolution(){
	$xeniaResolution
	echo "NYI"
}

Xenia_cleanESDE(){

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