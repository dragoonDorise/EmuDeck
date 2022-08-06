#!/bin/bash
#variables
SRM_toolName="Steam Rom Manager"
SRM_toolType="AppImage"
SRM_toolPath="${toolsPath}/srm/Steam-ROM-Manager.AppImage"
SRM_releaseURL="$(getLatestReleaseURLGH "SteamGridDB/steam-rom-manager" "AppImage")"

#cleanupOlderThings
SRM_cleanup(){
	rm -f "$HOME/Desktop/Steam-ROM-Manager-2.3.29.AppImage"
	rm -f "$HOME/Desktop/Steam-ROM-Manager.AppImage"
}

SRM_install(){		
	setMSG "Installing Steam Rom Manager"
	SRM_cleanup
	mkdir -p "${toolsPath}/srm"
	curl -L "$SRM_releaseURL" -o "$SRM_toolPath"
	chmod +x "$SRM_toolPath"
	SRM_createDesktopShortcut "$HOME/Desktop/SteamRomManager.desktop"
}

SRM_createDesktopShortcut(){
	SRM_Shortcutlocation=$1

	if [[ "$SRM_Shortcutlocation" == "" ]]; then

		SRM_Shortcutlocation="$HOME/Desktop/SteamRomManager.desktop"
	
	fi

echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Name=Steam Rom Manager
Exec=kill -15 \$(pidof steam) & $SRM_toolPath
Icon=steamdeck-gaming-return
Terminal=false
Type=Application
StartupNotify=false" > "$SRM_Shortcutlocation"
	chmod +x "$SRM_Shortcutlocation"
}

SRM_init(){			
	setMSG "Configuring Steam Rom Manager..."
	mkdir -p "$HOME/.config/steam-rom-manager/userData/"
	cp "$EMUDECKGIT/configs/steam-rom-manager/userData/userConfigurations.json" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
	cp "$EMUDECKGIT/configs/steam-rom-manager/userData/userSettings.json" "$HOME/.config/steam-rom-manager/userData/userSettings.json"

	sleep 3
	tmp=$(mktemp)
	jq -r --arg STEAMDIR "$HOME/.steam/steam" '.environmentVariables.steamDirectory = "\($STEAMDIR)"' \
	"$HOME/.config/steam-rom-manager/userData/userSettings.json"  > "$tmp"\
	 && mv "$tmp" "$HOME/.config/steam-rom-manager/userData/userSettings.json"
	
	tmp=$(mktemp)
	jq -r --arg ROMSDIR "$romsPath" '.environmentVariables.romsDirectory = "\($ROMSDIR)"' \
	"$HOME/.config/steam-rom-manager/userData/userSettings.json"  > "$tmp" \
	&& mv "$tmp" "$HOME/.config/steam-rom-manager/userData/userSettings.json"

	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
	sed -i "s|/run/media/mmcblk0p1/Emulation/storage|${storagePath}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
	sed -i "s|/home/deck|$HOME|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
	echo -e "OK!"
}