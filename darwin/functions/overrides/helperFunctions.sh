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
