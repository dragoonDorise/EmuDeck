#!/bin/bash

function darwin_installEmuDMG(){
	local name="$1"
	local url="$2"
	local altName="$3"
	local showProgress="$4"
	local lastVerFile="$5"
	local latestVer="$6"
	if [[ "$altName" == "" ]]; then
		altName="$name"
	fi
	echo "$name"
	echo "$url"
	echo "$altName"
	echo "$showProgress"
	echo "$lastVerFile"
	echo "$latestVer"

	mkdir -p "$HOME/Applications/EmuDeck"
	if safeDownload "$name" "$url" "$HOME/Applications/EmuDeck/$altName.dmg" "$showProgress"; then
		if [[ -n $lastVerFile ]] && [[ -n $latestVer ]]; then
			echo "latest version $latestVer > $lastVerFile"
			echo "$latestVer" > "$lastVerFile"
		fi
	else
		return 1
	fi


	shName=$(echo "$name" | awk '{print tolower($0)}')
	find "${toolsPath}/launchers/" -maxdepth 1 -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
	while read -r f
	do
		echo "deleting $f"
		rm -f "$f"
	done

	find "${EMUDECKGIT}/darwin/tools/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
	while read -r l
	do
		echo "deploying $l"
		launcherFileName=$(basename "$l")
		chmod +x "$l"
		cp -v "$l" "${toolsPath}/launchers/"
		chmod +x "${toolsPath}/launchers/"*
	done

}

function darwin_installEmuZip(){
	local name="$1"
	local url="$2"
	local altName="$3"
	local showProgress="$4"
	local lastVerFile="$5"
	local latestVer="$6"
	if [[ "$altName" == "" ]]; then
		altName="$name"
	fi

	mkdir -p "$HOME/Applications/EmuDeck"
	safeDownload "$name" "$url" "$HOME/Applications/EmuDeck/$altName.zip" "$showProgress"

	shName=$(echo "$name" | awk '{print tolower($0)}')
	find "${toolsPath}/launchers/" -maxdepth 1 -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
	while read -r f
	do
		echo "deleting $f"
		rm -f "$f"
	done

	find "${EMUDECKGIT}/darwin/tools/launchers/" -maxdepth 1 -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" -o -type f -iname "$shName-frontend.sh" | \
	while read -r l
	do
		echo "deploying $l"
		launcherFileName=$(basename "$l")
		chmod +x "$l"
		cp -v "$l" "${toolsPath}/launchers/"
		chmod +x "${toolsPath}/launchers/"*
	done

}


function darwin_generateAppfromSH(){
	local scriptPath=$1
	local appName=$2
	# Extrae el nombre base del script y elimina la extensión .sh
	rm -rf "/Applications/Emulators/$appName.app"
	mkdir -p "/Applications/Emulators/$appName.app/Contents/MacOS"
	#chmod +x "/Applications/Emulators/$appName.app"
	cp "./darwin/tools/appGenerator/Automator Application Stub" "/Applications/Emulators/$appName.app/Contents/MacOS/"
	cp "./darwin/tools/appGenerator/document.wflow" "/Applications/Emulators/$appName.app/Contents/"
	cp "./darwin/tools/appGenerator/Info.plist" "/Applications/Emulators/$appName.app/Contents/"
	sed -i "s|EMUDECKEMULATOR|${appName}|g" "/Applications/Emulators/$appName.app/Contents/document.wflow"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "/Applications/Emulators/$appName.app/Contents/document.wflow"
}
