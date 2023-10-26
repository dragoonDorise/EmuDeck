#!/bin/bash

zenityInfo(){
	local title=$1
	local text=$2
	text="`printf " <b>$title</b>\n\n$text)"`"
	 zenity --info \
			 --title="EmuDeck AutoFix" \
			 --width="450" \
			 --text="${text}" 2>/dev/null
}

autofix_duplicateESDE(){
	if [ -f "$toolsPath/launchers/esde/emulationstation-de.sh" ]; then
		rm -rf "$toolsPath/launchers/esde/emulationstation-de.sh"

		zenityInfo "EmulationStation DE duplicated launcher fixed" "We found you had an old EmulationStation DE launcher, we've deleted it so it wont appear as a duplicate on Steam Rom Manager. Delete both EmulationStation DE entries from Steam and parse back EmulationStation DE"
	fi
}

function autofix_raSavesFolders() {
	cloud_sync_createBackup "retroarch"
	sourceFolder="$savesPath/retroarch/saves"
	subfolders=$(find "$sourceFolder" -mindepth 1 -type d)

	if [[ $(echo "$subfolders" | wc -l) -gt 0 ]]; then
		cloud_sync_createBackup "retroarch"
		zenityInfo "Old RetroArch saves folders found" "EmuDeck will create a backup of them in Emulation/saves-backup just in case, after that it will reorganize and delete the old subfolder. Please manually delete all subfolders you might have in your cloud provider (EmuDeck/saves/retroarch/saves/* and EmuDeck/saves/retroarch/states/*)"
		for subfolder in $subfolders; do
			# cp -r "$subfolder"/* "$sourceFolder"
			rm -rf "$subfolder"
		done
	fi

	sourceFolder="$savesPath/retroarch/states"
	subfolders=$(find "$sourceFolder" -mindepth 1 -type d)

	if [[ $(echo "$subfolders" | wc -l) -gt 0 ]]; then
		for subfolder in $subfolders; do
			# cp -r "$subfolder" "$sourceFolder"
			rm -rf "$subfolder"
		done
	fi


	RetroArch_setConfigOverride "sort_savefiles_by_content_enable = " "false" "$RetroArch_configFile"
	RetroArch_setConfigOverride "sort_savefiles_enable" "false = " "$RetroArch_configFile"
	RetroArch_setConfigOverride "sort_savestates_by_content_enable = " "false" "$RetroArch_configFile"
	RetroArch_setConfigOverride "sort_savestates_enable = " "false" "$RetroArch_configFile"
	RetroArch_setConfigOverride "sort_screenshots_by_content_enable =" "false" "$RetroArch_configFile"
}