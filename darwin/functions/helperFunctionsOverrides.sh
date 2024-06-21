#!/bin/bash

function safeDownload() {
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



		if [[ $volumeName == *"ES-DE"* ]]; then
			cp -r "$volumeName"/*.app "$HOME/Applications/EmuDeck/ES-DE/"
		else
			cp -r "$volumeName"/*.app "$HOME/Applications/EmuDeck/"
		fi
		appName=$(find "$volumeName" -name "*.app" -exec basename {} \;)
		chmod +x  "$HOME/Applications/EmuDeck/$appName"

		find "$HOME/Applications/EmuDeck/" -maxdepth 1 -name "*.app" -exec ln -sf {} /Applications/ \;
		find "$HOME/Emulation/tools/launchers/" -maxdepth 2 -name "*.sh" -exec chmod +x {} \;

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

function addSteamInputCustomIcons() {
	rsync -av "$EMUDECKGIT/darwin/configs/steam-input/Icons/" "$HOME/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS/tenfoot/resource/images/library/controller/binding_icons/"
}

function getEmuInstallStatus() {
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

function checkInstalledEmus(){
	echo "no need"
}

function darwin_gcd() {
	while [ $2 -ne 0 ]; do
		set -- $2 $(( $1 % $2 ))
	done
	echo $1
}

function getScreenAR(){
	dimensions=$(system_profiler SPDisplaysDataType | awk '/Resolution/{print $2, $4}')

	width=$(echo $dimensions | cut -d ' ' -f 1)
	height=$(echo $dimensions | cut -d ' ' -f 2)


	g=$(darwin_gcd $width $height)

	aspect_ratio_width=$((width / g))
	aspect_ratio_height=$((height / g))

	return $aspect_ratio_width$aspect_ratio_height

}



function BINUP_install(){
	echo "no need, darwin"
}
function FlatpakUP_install(){
	echo "no need, darwin"
}
function CHD_install(){
	echo "no need, darwin"
}

function createDesktopIcons(){
	echo "no need, darwin"
}

function controllerLayout_BAYX(){
	echo "no need, darwin"
}
function controllerLayout_ABXY(){
	echo "no need, darwin"
}

function checkInstalledEmus(){
	echo "checkInstalledEmus darwin pending"
}