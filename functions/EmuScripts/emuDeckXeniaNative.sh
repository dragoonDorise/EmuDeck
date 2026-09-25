#!/usr/bin/env bash
#variables
XeniaNative_emuName="Xenia"
XeniaNative_emuType="${emuDeckEmuTypeAppImage:-AppImage}"

XeniaNative_appImageName="XeniaNative_canary_linux.AppImage"
XeniaNative_applicationsPath="${applicationsPath:-$HOME/Applications}"
XeniaNative_emuPath="${XeniaNative_applicationsPath}/${XeniaNative_appImageName}"
XeniaNative_releaseRepository="xenia-canary/xenia-canary"

XeniaNative_dataPath="$HOME/.local/share/Xenia"
XeniaNative_contentPath="${XeniaNative_dataPath}/content"
XeniaNative_patchesPath="${XeniaNative_dataPath}/patches"
XeniaNative_legacyPath="${romsPath}/xbox360"

XeniaNative_XeniaSettings="${XeniaNative_dataPath}/xenia-canary.config.toml"

#cleanupOlderThings
XeniaNative_cleanup(){
	echo "NYI"
}

XeniaNative_installLauncher(){
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
XeniaNative_install(){
	local version
	version=$1
	local showProgress="$2"
	local latestReleaseURL

	setMSG "Installing Xenia Canary"

	mkdir -p "$XeniaNative_applicationsPath"
	mkdir -p "$romsPath/xbox360"

	if [ $CPUarch == "arm" ]; then
		latestReleaseURL=$(getLatestReleaseURLGH "$XeniaNative_releaseRepository" ".AppImage" "edge" "xenia")
	else
		latestReleaseURL=$(getLatestReleaseURLGH "$XeniaNative_releaseRepository" ".AppImage" "linux" "Xenia_canary")
	fi

	if [[ -z "$latestReleaseURL" ]]; then
		echo "Could not find latest Xenia Canary Linux AppImage release."
		return 1
	fi

	echo "Downloading Xenia Canary from: $latestReleaseURL"

	if safeDownload "$XeniaNative_emuName" "$latestReleaseURL" "$XeniaNative_emuPath" "$showProgress"; then
		chmod +x "$XeniaNative_emuPath"
	else
		return 1
	fi

	XeniaNative_installLauncher

	rm -f "$HOME/.local/share/applications/xeniaNative.desktop"

	createDesktopShortcut   "$HOME/.local/share/applications/xeniaNative.desktop" \
							"Xenia" \
							"${toolsPath}/launchers/xeniaNative.sh" \
							"False"

	XeniaNative_flushEmulatorLauncher
	XeniaNative_addESConfig
	
	#Migration
	if [ ! -f "$XeniaNative_legacyPath/xenia.config.xml" ]; then
		XeniaNative_migrate
	fi
	
}

#ApplyInitialSettings
XeniaNative_init(){
	setMSG "Initializing Xenia Config"

	mkdir -p "$XeniaNative_dataPath"
	mkdir -p "$romsPath/xbox360/xbla"
	
	cp "$emudeckBackend/configs/xenia/xenia-canary.config.toml" "$XeniaNative_dataPath/xenia-canary.config.toml"	

	XeniaNative_setNativeConfigDefaults
	XeniaNative_setupSaves
	XeniaNative_getPatches
	XeniaNative_cleanESDE
	XeniaNative_flushEmulatorLauncher
	XeniaNative_addESConfig
	XeniaNative_addParser
}

XeniaNative_setNativeConfigDefaults(){
	if [ -f "$XeniaNative_XeniaSettings" ]; then
		sed -i 's|^gpu = .*|gpu = "vulkan"|' "$XeniaNative_XeniaSettings"
		sed -i 's|^fullscreen = .*|fullscreen = true|' "$XeniaNative_XeniaSettings"
	fi
}

XeniaNative_addESConfig(){
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
            <entry>${toolsPath}/launchers/xeniaNative.sh</entry>\\
        </rule>\\
    </emulator>
	" "$es_rulesFile"
}

XeniaNative_getPatches() {
	local patches_url="https://github.com/xenia-canary/game-patches/archive/refs/heads/main.zip"
	local zip="$XeniaNative_dataPath/game-patches.zip"

	mkdir -p "$XeniaNative_patchesPath"

	if curl -fL "$patches_url" -o "$zip" &>/dev/null; then
		nice -n 5 unzip -uqo "$zip" -d "$XeniaNative_dataPath" &>/dev/null
		rm -f "$zip"
		rsync -a --ignore-existing --remove-source-files "$XeniaNative_dataPath/game-patches-main/patches/" "$XeniaNative_patchesPath/" &> /dev/null
		rm -rf "$XeniaNative_dataPath/game-patches-main"
		echo "Xenia patches updated."
	else
		echo "Xenia patches download failed." >&2
		return 1
	fi
}


XeniaNative_cleanLegacyProtonInstall(){
	setMSG "Cleaning old Xenia Proton files"

	if [ -d "$XeniaNative_legacyPath" ]; then
		find "$XeniaNative_legacyPath" -mindepth 1 \( -name roms -o -name content -o -name xbla \) -prune -o -exec rm -rf '{}' \; &> /dev/null
	fi

	rm -f "$romsPath/xbox360/xenia.sh" &> /dev/null
}

#update
XeniaNative_update(){
	echo "NYI"
	XeniaNative_setupSaves
	XeniaNative_flushEmulatorLauncher
}

#ConfigurePaths
XeniaNative_setEmulationFolder(){
	echo "NYI"
}

#SetupSaves
XeniaNative_setupSaves(){
	mkdir -p "$XeniaNative_contentPath"
	unlink "$savesPath/xenia/saves"
	linkToSaveFolder xenia saves "$XeniaNative_contentPath"
}

#SetupStorage
XeniaNative_setupStorage(){
	echo "NYI"
}

#WipeSettings
XeniaNative_wipeSettings(){
	echo "NYI"
}

#Uninstall
XeniaNative_uninstall(){
	setMSG "Uninstalling $XeniaNative_emuName. Saves and ROMs will be retained."

	rm -f "$XeniaNative_emuPath" &> /dev/null
	rm -f "$HOME/.local/share/applications/xenia.desktop" &> /dev/null
	rm -f "${toolsPath}/launchers/xenia.sh" &> /dev/null
	rm -f "$romsPath/emulators/xenia.sh" &> /dev/null
	rm -f "$romsPath/xbox360/xenia.sh" &> /dev/null

	if [ -d "$XeniaNative_dataPath" ]; then
		find "$XeniaNative_dataPath" -mindepth 1 \( -name content \) -prune -o -exec rm -rf '{}' \; &> /dev/null
	fi
}

#setABXYstyle
XeniaNative_setABXYstyle(){
	echo "NYI"
}

#Migrate
XeniaNative_migrate(){
	#Check if the user has the linux port already installed to prevent overwriting it
	if [ -d $XeniaNative_dataPath ]; then
	
		#Xenia Native is already installed, we have to ask the user about what to do with its current saves	
		zenity --question --title "Xenia Native detected" --text "Xenia Native installation detected outside of EmuDeck. Do you want us to migrate your Xenia Proton saves from the EmuDeck installation? If you installed Xenia Native on your own those saves could be out of date" --cancel-label "Don't migrate saves" --ok-label "Migrate saves from EmuDeck's Xenia"
		if [ $? = 0 ]; then
			(			
				mv "$HOME/.local/share/Xenia/content" "$HOME/.local/share/Xenia/content_backup" && XeniaNative_migrateFunctions
			) | zenity --progress \
				--title="Migrating Xenia" \
				--text="Please stand by..." \
				--width=400 \
				--pulsate \
				--auto-close \
				--no-cancel
			
			zenity --info --width=400 --text="Xenia migration finished, we've kept a backup of your old saves in .local/share/Xenia/content_backup just in case"	
		else
			XeniaNative_migrateSRMparsers
			XeniaNative_addESConfig		
			XeniaNative_cleanLegacyProtonInstall
			zenity --info --width=400 --text="Xenia migration finished, we've only deleted Xenia Proton files and updated SRM entries and ESDE's settings to use EmuDeck's AppImage location to ensure future updates. Your current saves and configurations were preserved. If you want to manually reset your settings please do so in Manage Emulators"		
		fi
		
	else		
		(			
			XeniaNative_migrateFunctions
		) | zenity --progress \
			--title="Migrating Xenia" \
			--text="Please stand by..." \
			--width=400 \
			--pulsate \
			--auto-close \
			--no-cancel
			
		zenity --info --width=400 --text="Xenia Proton sucessfully migrated to Xenia Native. We've updated ESDE and SRM with the new paths and migrated your settings and saves. You can now go back to gaming mode if you want"
	fi	
	
}

XeniaNative_migrateFunctions(){
	XeniaNative_init
	XeniaNative_migrateLegacyData
	XeniaNative_migrateLegacySaves
	XeniaNative_migrateLegacySRMparsers
	XeniaNative_cleanLegacyProtonInstall
	XeniaNative_install
}


XeniaNative_migrateLegacyData(){
	mkdir -p "$XeniaNative_dataPath"

	cp "$XeniaNative_legacyPath/xenia.config.toml" "$XeniaNative_dataPath/xenia.config.toml.legacy"	
	cp "$XeniaNative_legacyPath/xenia-canary.config.toml" "$XeniaNative_dataPath/xenia-canary.config.toml.legacy"
	
	if [ -d "$XeniaNative_legacyPath/patches" ]; then
		mkdir -p "$XeniaNative_patchesPath"
		rsync -a --remove-source-files "$XeniaNative_legacyPath/patches/" "$XeniaNative_patchesPath/" &> /dev/null
	fi	
}

XeniaNative_migrateLegacySRMparsers(){
	#SRM parsers
	local old_path="Z:$romsPath/xbox360"
	local new_path="$romsPath/xbox360"
	kill -15 $(pidof steam)
	find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vdf" -exec sed -i "s|${old_path}|${new_path}|g" {} +
	SRM_addExtraParsers	
}

XeniaNative_migrateLegacySaves(){
	local legacyContentPath="$romsPath/xbox360/content"

	if [ -d "$legacyContentPath" ]; then
		mkdir -p "$XeniaNative_contentPath"
		rsync -a --remove-source-files "$legacyContentPath/" "$XeniaNative_contentPath/" &> /dev/null
	fi
}


#WideScreenOn
XeniaNative_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
XeniaNative_wideScreenOff(){
	echo "NYI"
}

#BezelOn
XeniaNative_bezelOn(){
	echo "NYI"
}

#BezelOff
XeniaNative_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
XeniaNative_finalize(){
	XeniaNative_cleanup
}

XeniaNative_IsInstalled(){
	if [ -e "$XeniaNative_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

XeniaNative_resetConfig(){
	mv "$XeniaNative_XeniaSettings" "$XeniaNative_XeniaSettings.bak" &> /dev/null
	XeniaNative_init &> /dev/null && echo "true" || echo "false"
}

XeniaNative_setResolution(){
	$xeniaResolution
	echo "NYI"
}

XeniaNative_cleanESDE(){

	if [ -d "${romsPath}/xbox360/.git" ]; then
		rm -rf "${romsPath}/xbox360/.git"
	fi

	if [ -f "$romsPath/xbox360/LICENSE" ]; then
		mv -f "$romsPath/xbox360/LICENSE" "$romsPath/xbox360/LICENSE.TXT"
	fi
}

XeniaNative_flushEmulatorLauncher(){
	flushEmulatorLaunchers "xenia"
}

XeniaNative_addParser(){
	addParser "microsoft_xbox360_iso_xenia.json"
	addParser "microsoft_xbox360_xbla_xenia.json"
}
