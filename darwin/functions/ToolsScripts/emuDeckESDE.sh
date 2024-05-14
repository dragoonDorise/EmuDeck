#!/bin/bash
function ESDE_customDesktopShortcut(){
	mkdir -p "$toolsPath/launchers/es-de"
	cp "$EMUDECKGIT/darwin/tools/launchers/es-de/es-de.sh" "$toolsPath/launchers/es-de/ES-DE.sh"
	darwin_ESDE_GenerateApp "$toolsPath/launchers/es-de/ES-DE.sh"
}

function ESDE_SetAppImageURLS() {
	local json="$(curl -s $ESDE_releaseJSON)"

	mkdir -p $HOME/Applications/EmuDeck/ES-DE

	if [ appleChip == 'arm64' ]; then
		ESDE_releaseURL=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "macOSApple") | .url')
	else
		ESDE_releaseURL=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "macOSApple") | .url')
	fi
	#
}

function darwin_ESDE_GenerateApp(){
	local appName="ES-DE"
	# Extrae el nombre base del script y elimina la extensión .sh
	rm -rf "/Applications/$appName.app"
	mkdir -p "/Applications/$appName.app/Contents/MacOS"
	#chmod +x "/Applications/Emulators/$appName.app"
	cp "./darwin/tools/appGenerator/Automator Application Stub" "/Applications/$appName.app/Contents/MacOS/"
	cp "./darwin/tools/appGenerator/document.wflow" "/Applications/$appName.app/Contents/"
	cp "./darwin/tools/appGenerator/Info.plist" "/Applications/$appName.app/Contents/"
	sed -i "s|EMUDECKEMULATOR|es-de/${appName}|g" "/Applications/$appName.app/Contents/document.wflow"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "/Applications/$appName.app/Contents/document.wflow"
	fileicon set /Applications/ES-DE.app "$HOME/.config/EmuDeck/backend/icons/ES-DE.png"
}

function ESDE_migration(){
	echo "no need on darwin"
}


function ESDE_addCustomSystems(){
	echo "no need on darwin"
}
function ESDE_addCustomSystemsFile(){
	echo "no need on darwin"
}
function ESDE_update(){
	echo "no need on darwin"
}

ESDE_IsInstalled(){
	[ -e '/Applications/ES-DE.app' ] && echo "true" || echo "false"
}
ESDE_uninstall(){
	rm -rf '/Applications/ES-DE.app'
	rm -rf "$HOME/Applications/EmuDeck/ES-DE/ES-DE.app"
	rm -rf "$toolsPath/launchers/es-de/ES-DE.sh"
}

ESDE_createLauncher(){
 mkdir -p "$toolsPath/launchers/es-de"
 cp -r "$EMUDECKGIT/darwin/tools/launchers/es-de/es-de.sh" "$toolsPath/launchers/es-de/ES-DE.sh" && chmod +x "$toolsPath/launchers/es-de/ES-DE.sh"
}

ESDE_flushToolLauncher(){
	ESDE_createLauncher
}