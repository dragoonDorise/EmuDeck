#!/bin/bash
API_pull(){
	local branch = $1
	cd ~/.config/EmuDeck/backend && touch ~/emudeck/logs/git.log && script ~/emudeck/logs/git.log -c 'git reset --hard && git clean -fd && git checkout $branch && git pull' && appImageInit
}

API_autoSave(){
	RetroArch_autoSave
}

API_bezels(){
	RetroArch_setBezels
}

API_shaders_LCD(){
	RetroArch_setShadersMAT
}

API_shaders_2D(){
	RetroArch_setShadersCRT
}

API_shaders_3D(){
	RetroArch_setShaders3DCRT
}

API_ar_snes(){
	if [ "$arSnes" == 87 ]; then
		RetroArch_snes_ar87
		RetroArch_nes_ar87
	else
		RetroArch_snes_ar43
		RetroArch_nes_ar43
	fi
}


API_setAR(){
	RetroArch_setCustomizations
	Xemu_setCustomizations
	DuckStation_setCustomizations
	PCSX2QT_setCustomizations
	Dolphin_setCustomizations
}

API_setCloud(){
  if [ $cloud_sync_status == "false" ]; then
	setSetting cloud_sync_status "true" > /dev/null
  else
	  setSetting cloud_sync_status "false" > /dev/null
  fi
}

API_setToken(){
	local token=$1
	local user=$2
	echo $token > "$HOME/.config/EmuDeck/.rat" && echo $user > "$HOME/.config/EmuDeck/.rau" && RetroArch_retroAchievementsSetLogin && DuckStation_retroAchievementsSetLogin && PCSX2QT_retroAchievementsSetLogin && echo true
}

API_getToken(){
	local escapedUserName=$1
	local escapedPass=$2
	curl --location --data-urlencode u='$escapedUserName' --data-urlencode p='$escapedPass' --request POST 'https://retroachievements.org/dorequest.php?r=login'
}

API_optional_parsers(){
	echo "true"
}



