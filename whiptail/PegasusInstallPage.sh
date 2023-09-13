#!/bin/bash

if [ $android -gt 10 ]; then
	frontends=$(whiptail --title "Choose your Frontend" \
   --checklist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
	"PEGASUS" "Pegasus - You'll need to scrap your artwork on a PC" OFF \
	"DAIJISHO" "Daihisho - Recommended" OFF \
	"DIG" "Dig" OFF \
	"RESET" "Reset Collection - Paid" OFF \
	"ARC" "Arc Browser - Paid" OFF \
   3>&1 1<&2 2>&3)
 else
 	frontends=$(whiptail --title "Choose your Frontend" \
	--checklist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
	 "PEGASUS" "Pegasus - Automatic configuration" OFF \
	 "DAIJISHO" "Daihisho - Recommended" OFF \
	 "DIG" "Dig" OFF \
	 "RESET" "Reset Collection - Paid" OFF \
	 "ARC" "Arc Browser - Paid" OFF \
	3>&1 1<&2 2>&3)
 fi
 mapfile -t settingsFrontends <<< $frontends
 
 
 for settingsFrontend in "${settingsFrontends[@]}";
  do
	  if [[ $settingsFrontend == *"PEGASUS"* ]]; then
		 setSetting doInstallPegasus true
	 fi
	 if [[ $settingsFrontend == *"DAIJISHO"* ]]; then
		 setSetting doInstallDaijisho true
	 fi
	 if [[ $settingsFrontend == *"DIG"* ]]; then
		 setSetting doInstallDig true
	 fi
	 if [[ $settingsFrontend == *"LAUNCHBOX"* ]]; then
		 setSetting doInstallLaunchbox true
	 fi
	 if [[ $settingsFrontend == *"RESET"* ]]; then
		 setSetting doInstallReset true
	 fi
	 if [[ $settingsFrontend == *"ARC"* ]]; then
		 setSetting doInstallArc true
	 fi
  done
