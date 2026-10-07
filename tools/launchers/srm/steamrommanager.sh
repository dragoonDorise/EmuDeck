#!/usr/bin/env bash
cd "$HOME/.config/EmuDeck/backend/"
git pull
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
launcherInit

sandbox=""

if $(grep -q Ubuntu /etc/os-release) ; then
	sandbox="--no-sandbox"
fi

if [ -e "${toolsPath}/Steam-ROM-Manager.AppImage" ]; then 
	SRM_toolPath="${toolsPath}/Steam-ROM-Manager.AppImage"
elif [ -e "${toolsPath}/Steam ROM Manager.AppImage" ]; then
	SRM_toolPath="${toolsPath}/Steam ROM Manager.AppImage"
elif [ -e "${toolsPath}/srm/Steam-ROM-Manager.AppImage" ]; then
	SRM_toolPath="${toolsPath}/srm/Steam-ROM-Manager.AppImage"
else
	SRM_install
	SRM_init
fi

SRM_checkParsers

if [ "$(getProductName)" != "frame" ]; then

	if grep -q '"autoKillSteam": true' "$HOME/.config/steam-rom-manager/userData/userSettings.json"; then
		echo "Steam ROM Manager path: $SRM_toolPath"
		echo "autoKillSteam set to true in Steam ROM Manager. Skipping zenity prompt."
		$($SRM_toolPath $sandbox)
	else
		echo "Steam ROM Manager path: $SRM_toolPath"
		echo "autoKillSteam set to false in Steam ROM Manager. Loading zenity prompt."
		zenity --question \
			--width 450 \
			--title "Close Steam/Steam Input?" \
			--text "Exit Steam to launch Steam ROM Manager? Desktop controls will revert to Lizard Mode until Steam is reopened. Use L2/R2 to click and the trackpad to move the cursor." && (kill -15 $(pidof steam) & $($SRM_toolPath $sandbox))
	fi
else


	#We get the hash for the current state of the non steam shortcuts for all shortcuts.vdf files
	shortcutsHash=$(find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vdf" -exec md5sum {} + 2>/dev/null | sort | md5sum)

	zenity --question \
	--width 450 \
	--title "Steam Frame special instructions" \
	--text "Remember to exit Steam Rom Manager after adding your games or they won't appear in your library." && $($SRM_toolPath $sandbox)
	
	#We check the hash again to see if there's been any changes...
	newShortcutsHash=$(find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vdf" -exec md5sum {} + 2>/dev/null | sort | md5sum)

	#Changes? We show a zenity asking the user to restart steam
	if [ "$shortcutsHash" != "$newShortcutsHash" ]; then
		zenity --question \
			--width 450 \
			--title "Restart Steam?" \
			--text "Steam ROM Manager has changed your Steam shortcuts. Restart Steam now to see them?" && killSteam
	fi

fi