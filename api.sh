#!/bin/bash
. $HOME/.config/EmuDeck/backend/functions/all.sh

API_pull(){
	local branch=$1
	cd ~/.config/EmuDeck/backend && touch ~/emudeck/logs/git.log && git reset --hard && git clean -fd && git checkout $branch && git pull && appImageInit && echo "OK" || echo "KO" >&2
}

API_autoSave(){
	RetroArch_autoSave 1> /dev/null && echo "OK" || echo "KO" >&2
}

API_bezels(){
	RetroArch_setBezels 1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_shaders_LCD(){
	RetroArch_setShadersMAT 1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_shaders_CRT(){
	RetroArch_setShadersCRT 1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_shaders_3D(){
	RetroArch_setShaders3DCRT 1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_ar_snes(){
	if [ "$arSnes" == 87 ]; then
		RetroArch_snes_ar87  1> /dev/null && RetroArch_nes_ar87 1> /dev/null && echo "OK" || echo "KO" >&2
	else
		RetroArch_snes_ar43 1> /dev/null && RetroArch_nes_ar43 1> /dev/null  && echo "OK" || echo "KO" >&2
	fi
}

API_ar_sega(){
	RetroArch_mastersystem_ar32 1> /dev/null && RetroArch_genesis_ar32 1> /dev/null && RetroArch_segacd_ar32 1> /dev/null && RetroArch_sega32x_ar32 1> /dev/null && echo "OK" || echo "KO" >&2
}

API_ar_gamecube(){
	Dolphin_setCustomizations 1> /dev/null && echo "OK" || echo "KO" >&2
}

API_setAR(){
	RetroArch_setCustomizations 1> /dev/null && Xemu_setCustomizations 1> /dev/null && DuckStation_setCustomizations 1> /dev/null && PCSX2QT_setCustomizations 1> /dev/null && Dolphin_setCustomizations 1> /dev/null && echo "OK" || echo "KO" >&2
}

API_setCloud(){
  if [ $cloud_sync_status == "false" ]; then
	setSetting cloud_sync_status "true" 1> /dev/null && echo "OK" || echo "KO" >&2
  else
	  setSetting cloud_sync_status "false" 1> /dev/null && echo "OK" || echo "KO" >&2
  fi
}

API_setToken(){
	local token=$1
	local user=$2
	echo $token > "$HOME/.config/EmuDeck/.rat" && echo $user > "$HOME/.config/EmuDeck/.rau" && RetroArch_retroAchievementsSetLogin && DuckStation_retroAchievementsSetLogin && PCSX2QT_retroAchievementsSetLogin && echo "OK" || echo "KO" >&2
}

API_getToken(){
	local escapedUserName=$1
	local escapedPass=$2
	curl --location --data-urlencode u='$escapedUserName' --data-urlencode p='$escapedPass' --request POST 'https://retroachievements.org/dorequest.php?r=login' && echo "OK" || echo "KO" >&2
}

API_cloudSyncHealth(){
	cloudSyncHealth 1> /dev/null && echo "OK" || echo "KO" >&2
}

API_RetroArch_install(){
	RetroArch_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_Dolphin_install(){
	Dolphin_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_PrimeHack_install(){
	PrimeHack_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_PPSSPP_install(){
	PPSSPP_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_DuckStation_install(){
	DuckStation_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_melonDS_install(){
	melonDS_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_Citra_install(){
	Citra_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_PCSX2_install(){
	PCSX2_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_RPCS3_install(){
	RPCS3_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_Yuzu_install(){
	Yuzu_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_Ryujinx_install(){
	Ryujinx_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_Xemu_install(){
	Xemu_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_SRM_install(){
	SRM_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_RMG_install(){
	RMG_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_MAME_install(){
	MAME_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_Vita3K_install(){
	Vita3K_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_Flycast_install(){
	Flycast_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_ScummVM_install(){
	ScummVM_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}


API_Xenia_install(){
	Xenia_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}


API_mGBA_install(){
	mGBA_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}


API_ESDE_install(){
	ESDE_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}

API_Pegasus_install(){
	Pegasus_install  1> /dev/null  && echo "OK" || echo "KO" >&2
}