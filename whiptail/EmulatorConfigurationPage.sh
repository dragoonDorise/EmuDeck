#!/bin/bash

setSetting doSetupRA false
setSetting doSetupDolphin false
setSetting doSetupPCSX2 false
setSetting doSetupCitra false
setSetting doSetupDuck false
setSetting doSetupPPSSPP false
setSetting doSetupSkyline false
setSetting doSetupDrastic false

case $devicePower in
"0")	
	
		emulators=$(whiptail --title "Overwrrite Emulators Settings?" \
	   --checklist "If you want to keep your custom setting for some emus, leave them unchecked. Checked means we will overwrite your configuration" 10 80 4 \
		"RA" "RetroArch - Classic 2D and 3D Games" ON \
		"DOLPHIN" "Dolphin - GameCube and Wii" ON \
		"DUCK" "Duckstation - Playstation 1" ON \
		"AETHERSX2" "AetherSX2 - Playstation 2" ON \
		"CITRA" "Citra - Nintendo 3DS" ON \
		"PPSSPP" "PPSSPP - Sony PSP" ON \
		"SKYLINE" "PPSSPP - Nintendo Switch" ON \
	   3>&1 1<&2 2>&3)
		
;;
"1")	
	
		emulators=$(whiptail --title "Overwrrite Emulators Settings?" \
	   --checklist "If you want to keep your custom setting for some emus, leave them unchecked. Checked means we will overwrite your configuration" 10 80 4 \
		"RA" "RetroArch - Classic 2D and 3D Games" ON \
		"DOLPHIN" "Dolphin - GameCube and Wii" ON \
		"DUCK" "Duckstation - Playstation 1" ON \
		"AETHERSX2" "AetherSX2 - Playstation 2" ON \
		"CITRA" "Citra - Nintendo 3DS" ON \
		"PPSSPP" "PPSSPP - Sony PSP" ON \
		"SKYLINE" "PPSSPP - Nintendo Switch" ON \
	   3>&1 1<&2 2>&3)

;;
"2")
	
		emulators=$(whiptail --title "Overwrrite Emulators Settings?" \
	   --checklist "If you want to keep your custom setting for some emus, leave them unchecked. Checked means we will overwrite your configuration" 10 80 4 \
		"RA" "RetroArch - Classic 2D and 3D Games" ON \
		"DOLPHIN" "Dolphin - GameCube and Wii" ON \
		"DUCK" "Duckstation - Playstation 1" ON \
		"AETHERSX2" "AetherSX2 - Playstation 2" ON \
		"CITRA" "Citra - Nintendo 3DS" ON \
		"PPSSPP" "PPSSPP - Sony PSP" ON \
		"SKYLINE" "PPSSPP - Nintendo Switch" ON \
	   3>&1 1<&2 2>&3)
;;
*)
	echo "default"
;;
esac


mapfile -t settingsEmus <<< $emulators

for settingsEmu in "${settingsEmus[@]}";
 do
	 if [[ $settingsEmu = *"RA"* ]]; then
		setSetting doSetupRA true
	fi
	if [[ $settingsEmu = *"DOLPHIN"* ]]; then
		setSetting doSetupDolphin true
	fi
	if [[ $settingsEmu = *"DUCK"* ]]; then
		setSetting doSetupDuck true
	fi
	if [[ $settingsEmu = *"AETHERSX2"* ]]; then
		setSetting doSetupPCSX2 true
	fi
	if [[ $settingsEmu = *"CITRA"* ]]; then
		setSetting doSetupCitra true
	fi
	if [[ $settingsEmu = *"PPSSPP"* ]]; then
		setSetting doSetupPPSSPP true
	fi
	if [[ $settingsEmu = *"SKYLINE"* ]]; then
		setSetting doSetupSkyline true
	fi	
 done