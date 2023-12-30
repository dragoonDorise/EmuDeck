#!/bin/bash

safeDownload() {
	local name="$1"
	local url="$2"
	local outFile="$3"
	local showProgress="$4"
	local headers="$5"
	if [ "$showProgress" == "true" ]; then
		echo "safeDownload()"
		echo "- $name"
		echo "- $url"
		echo "- $outFile"
		echo "- $showProgress"
		echo "- $headers"
	fi

	request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 && echo $'\2'0 || echo $'\2'$?)

	returnCodes="${request#*$'\1'}"
	httpCode="${returnCodes%$'\2'*}"
	exitCode="${returnCodes#*$'\2'}"

	if [ "$httpCode" = "200" ] && [ "$exitCode" == "0" ]; then
		#echo "$name downloaded successfully";
		mv -v "$outFile.temp" "$outFile" &>/dev/null
		volumeName=$(yes | hdiutil attach "$outFile" | grep -o '/Volumes/.*$')

		if [ -z "$volumeName" ]; then
			unzip "$outFile";
			volumeName="$HOME/Applications/EmuDeck/$outFile"
		fi

		cp -r "$volumeName"/*.app "$HOME/Applications/EmuDeck/"

		appName=$(find "$volumeName" -name "*.app" -exec basename {} \;)
		chmod +x  "$HOME/Applications/EmuDeck/$appName"

		find "$HOME/Applications/EmuDeck/" -maxdepth 1 -name "*.app" -exec ln -s {} /Applications/ \;
		#chmod +x  "/Applications/$appName"
		if [ -n "$volumeName" ]; then
			hdiutil detach "$volumeName" && rm -rf "$outFile"
		fi
		return 0
	else
		#echo "$name download failed"
		rm -f "$outFile.temp"
		return 1
	fi

}

addSteamInputCustomIcons() {
	rsync -av "$EMUDECKGIT/darwin/configs/steam-input/Icons/" "$HOME/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS/tenfoot/resource/images/library/controller/binding_icons/"
}



getEmuInstallStatus() {
	echo "NYI"
}




function createUpdateSettingsFile(){
	#!/bin/bash

	if [ ! -e "$emuDecksettingsFile" ]; then
		echo "#!/bin/bash"> "$emuDecksettingsFile"
	fi
	local defaultSettingsList=()
	defaultSettingsList+=("doInstallSRM=true")
	defaultSettingsList+=("doInstallRA=true")
	defaultSettingsList+=("doSetupDolphin=false")
	defaultSettingsList+=("doSetupmelonDS=false")
	defaultSettingsList+=("doInstallmelonDS=false")
	defaultSettingsList+=("doSetupRPCS3=false")
	defaultSettingsList+=("doSetupYuzu=false")
	defaultSettingsList+=("doSetupCitra=false")
	defaultSettingsList+=("doSetupDuck=false")
	defaultSettingsList+=("doSetupCemu=false")
	defaultSettingsList+=("doSetupXenia=false")
	defaultSettingsList+=("doSetupRyujinx=false")
	defaultSettingsList+=("doSetupMAME=false")
	defaultSettingsList+=("doSetupPrimehack=false")
	defaultSettingsList+=("doSetupPPSSPP=false")
	defaultSettingsList+=("doSetupXemu=false")
	defaultSettingsList+=("doSetupPCSX2QT=false")
	defaultSettingsList+=("doSetupScummVM=false")
	defaultSettingsList+=("doSetupVita3K=false")
	defaultSettingsList+=("doSetupRMG=false")
	defaultSettingsList+=("doSetupMGBA=false")
	defaultSettingsList+=("doSetupFlycast=false")
	defaultSettingsList+=("doInstallDolphin=false")
	defaultSettingsList+=("doInstallMAME=false")
	defaultSettingsList+=("doInstallRyujinx=false")
	defaultSettingsList+=("doInstallRPCS3=false")
	defaultSettingsList+=("doInstallYuzu=false")
	defaultSettingsList+=("doInstallCitra=false")
	defaultSettingsList+=("doInstallDuck=false")
	defaultSettingsList+=("doInstallCemu=false")
	defaultSettingsList+=("doInstallXenia=false")
	defaultSettingsList+=("doInstallPrimeHack=false")
	defaultSettingsList+=("doInstallPPSSPP=false")
	defaultSettingsList+=("doInstallXemu=false")
	defaultSettingsList+=("doInstallPCSX2QT=false")
	defaultSettingsList+=("doInstallScummVM=false")
	defaultSettingsList+=("doInstallVita3K=false")
	#defaultSettingsList+=("doInstallMelon=false")
	defaultSettingsList+=("doInstallMGBA=false")
	defaultSettingsList+=("doInstallFlycast=false")
	defaultSettingsList+=("doInstallCHD=false")
	defaultSettingsList+=("doInstallPowertools=false")
	defaultSettingsList+=("doInstallGyro=false")
	defaultSettingsList+=("doInstallHomeBrewGames=false")
	defaultSettingsList+=("installString='Installing'")

	tmp=$(mktemp)
	#sort "$emuDecksettingsFile" | uniq -u > "$tmp" && mv "$tmp" "$emuDecksettingsFile"

	cat "$emuDecksettingsFile" | awk '!unique[$0]++' > "$tmp" && mv "$tmp" "$emuDecksettingsFile"
	for setting in "${defaultSettingsList[@]}"
		do
			local settingName=$(cut -d "=" -f1 <<< "$setting")
			local settingVal=$(cut -d "=" -f2 <<< "$setting")
			if grep -r "^${settingName}=" "$emuDecksettingsFile" &>/dev/null; then
				echo "Setting: $settingName found. CurrentValue: $(getSetting "$settingName")"
				setSetting "$settingName" "$settingVal"
			else
				echo "Setting: $settingName NOT found. adding to $emuDecksettingsFile with default value: $settingVal"
				setSetting "$settingName" "$settingVal"
			fi
		done

}


function createDesktopShortcut(){
	echo "no need"
}