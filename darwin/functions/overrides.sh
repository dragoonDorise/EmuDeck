#!/bin/bash
#We set the proper sed

#Override Vars
SRM_toolPath="Applications/Steam ROM Manager.app"

RetroArch_configFile="$HOME/Library/Application Support/RetroArch/config/retroarch.cfg"
RetroArch_coreConfigFolders="$HOME/Library/Application Support/RetroArch/config"	
RetroArch_cores="$HOME/Library/Application Support/RetroArch/cores"	
RetroArch_path="$HOME/Library/Application Support/RetroArch"
RetroArch_coresURL="https://buildbot.libretro.com/nightly/apple/osx/${appleChip}/latest/"
RetroArch_coresExtension="dylib.zip"


ESDE_toolPath="$HOME/Application/EmulationStation Desktop Edition.app"
ESDE_addSteamInputFile="$EMUDECKGIT/darwin/configs/steam-input/emulationstation-de_controller_config.vdf"
steam_input_templateFolder="$HOME/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS/controller_base/templates/"

SRM_userData_directory="darwin/configs/steam-rom-manager/userData"

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

		cp -r "$volumeName"/*.app "$HOME/Applications/EmuDeck/"		

		appName=$(find "$volumeName" -name "*.app" -exec basename {} \;)				
		chmod +x  "$HOME/Applications/EmuDeck/$appName"	
		
		find "$HOME/Applications/EmuDeck/" -name "*.app" -exec ln -s {} /Applications/ \;		
		#chmod +x  "/Applications/$appName"
		hdiutil detach "$volumeName" && rm -rf $outFile

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


#!/bin/bash
configEmuFP(){		
	
	local name=$1
	
	setMSG "Updating $name Config"	
	
	rsync -avhpL --mkpath "$EMUDECKGIT/darwin/configs/${name}/" "$HOME/Library/Application Support/${name}/"

}
