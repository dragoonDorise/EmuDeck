#!/bin/bash
source "$HOME/.config/EmuDeck/backend/functions/all.sh"

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

zenity --question \
	--width 450 \
	--title "Close Steam/Steam Input?" \
	--text "Exit Steam to launch Steam ROM Manager? Desktop controls will revert to Lizard Mode until Steam is reopened. Use L2/R2 to click and the trackpad to move the cursor." && (kill -15 $(pidof steam) & "$SRM_toolPath")
