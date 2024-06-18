#!/bin/bash
installEmuFP(){		
	
	local name="$1"
	local ID="$2"
	local type="$3"

	if [[ "$type" == "emulator" ]]; then
		gitPath="${EMUDECKGIT}/tools/launchers/"
		launcherPath="${toolsPath}/launchers"
	elif [[ "$type" == "remoteplay" ]]; then
		gitPath="${EMUDECKGIT}/tools/remoteplayclients/"
		launcherPath="${romsPath}/remoteplay"
	elif [[ "$type" == "genericapplication" ]]; then
		gitPath="${EMUDECKGIT}/tools/generic-applications/"
		launcherPath="${romsPath}/generic-applications"
	fi
	
	setMSG "Installing $name"
	
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
	#remove old system flatpak after we detect user flatpak is installed
	if [ "$(flatpak --columns=app list --user | grep "$ID")" == "$ID" ]; then
		flatpak uninstall "$ID" --system -y
	fi
 	
  	if [[ "$type" == "emulator" ]]; then
        shName=$(echo "$name" | awk '{print tolower($0)}')-emu
    else
        shName=$(echo "$name" | awk '{print tolower($0)}')
    fi 
	
	find "$launcherPath" -maxdepth 1 -type f \( -iname "${shName}.sh" -o -iname "${shName}.sh" \) | while read -r f; do
		echo "deleting old: $f"
		rm -f "$f"
	done

	find "$gitPath" -type f \( -iname "${shName}.sh" -o -iname "${shName}.sh" \) | while read -r l; do
		echo "deploying new: $l"
		chmod +x "$l"
		cp -v "$l" "${launcherPath}"
	done
}
