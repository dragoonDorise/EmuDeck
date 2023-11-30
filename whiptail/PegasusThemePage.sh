#!/bin/bash
# themesQ=$(whiptail --title "Pegasus Theme" \
# --checklist "What Pegasus theme do you want to install" 10 80 4 \
# "EPIC" "RP - Epic Noir" ON \
# "SWITCH" "RP - Switch" OFF \
# "MEGA" "Retro Mega" OFF \
# "GAMEOS" "GameOS" OFF \
# "NEORETRO" "NeoRetro Dark" OFF \
# 3>&1 1<&2 2>&3)
# 
# mapfile -t themes <<< themesQ
#  
#  for theme in ${themes[@]};
#   do
# 	  if [[ $theme == *"EPIC"* ]]; then
# 		 setSetting doInstallThemeEpic true
# 	 fi
# 	 if [[ $theme == *"SWITCH"* ]]; then
# 		 setSetting doInstallThemeSwitch true
# 	 fi
# 	 if [[ $theme == *"MEGA"* ]]; then
# 		 setSetting doInstallThemeMega true
# 	 fi
# 	 if [[ $theme == *"GAMEOS"* ]]; then
# 		 setSetting doInstallThemeGameOS true
# 	 fi
# 	 if [[ $theme == *"NEORETRO"* ]]; then
# 		 setSetting doInstallThemeNeoRetro true
# 	 fi
#   done