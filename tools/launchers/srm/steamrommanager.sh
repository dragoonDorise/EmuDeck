#!/bin/bash
source "$HOME/.config/EmuDeck/backend/functions/all.sh"
SRM_toolPath="${toolsPath}/Steam ROM Manager.AppImage"

#SRM_createParsers
SRM_addSteamInputProfiles

zenity --question \
	--width 450 \
	--title "Close Steam/Steam Input?" \
	--text "Exit Steam to launch Steam ROM Manager? Desktop controls will revert to Lizard Mode until Steam is reopened. Use L2/R2 to click and the trackpad to move the cursor." && (kill -15 $(pidof steam) & "$SRM_toolPath")
