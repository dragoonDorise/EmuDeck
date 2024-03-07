#!/bin/bash
source "$HOME/.config/EmuDeck/backend/functions/all.sh"
SRM_toolPath="${toolsPath}/Steam ROM Manager.AppImage"

if grep -q "mmcblk0p1" "$SRM_userData_configDir/userConfigurations.json"; then
	SRM_init
	text="$(printf "<b>Parsers fixed</b>\nWe've detected an issue with Steam Rom Manager, but it's been fixed")"
	zenity --info \
		--title="EmuDeck" \
		--width="450" \
		--text="${text}" 2>/dev/null
fi
SRM_addSteamInputProfiles

zenity --question \
	--width 450 \
	--title "Close Steam/Steam Input?" \
	--text "Exit Steam to launch Steam ROM Manager? Desktop controls will revert to Lizard Mode until Steam is reopened. Use L2/R2 to click and the trackpad to move the cursor." && (kill -15 $(pidof steam) & "$SRM_toolPath")
