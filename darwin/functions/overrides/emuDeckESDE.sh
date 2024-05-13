#!/bin/bash
ESDE_customDesktopShortcut(){
	mkdir -p "$toolsPath/launchers/es-de"
	cp "$EMUDECKGIT/darwin/tools/launchers/es-de/es-de.sh" "$toolsPath/launchers/es-de/es-de.sh"
	darwin_ESDE_GenerateApp "$toolsPath/launchers/es-de/es-de.sh"
}

ESDE_SetAppImageURLS() {
	local json="$(curl -s $ESDE_releaseJSON)"

	if [ appleChip == 'arm64' ]; then
		ESDE_releaseURL=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "macOSApple") | .url')
	else
		ESDE_releaseURL=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "macOSApple") | .url')
	fi
	#
}

function darwin_ESDE_GenerateApp(){
	local scriptPath=$1
	local appName="ES-DE"
	# Extrae el nombre base del script y elimina la extensión .sh
	rm -rf "/Applications/Emulators/es-de/$appName.app"
	mkdir -p "/Applications/Emulators/es-de/$appName.app/Contents/MacOS"
	#chmod +x "/Applications/Emulators/$appName.app"
	cp "./darwin/tools/appGenerator/Automator Application Stub" "/Applications/$appName.app/Contents/MacOS/"
	cp "./darwin/tools/appGenerator/document.wflow" "/Applications/$appName.app/Contents/"
	cp "./darwin/tools/appGenerator/Info.plist" "/Applications/$appName.app/Contents/"
	sed -i "s|EMUDECKEMULATOR|es-de/${appName}|g" "/Applications/$appName.app/Contents/document.wflow"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "/Applications/$appName.app/Contents/document.wflow"
}

function ESDE_migration(){
	echo "no need on darwin"
}