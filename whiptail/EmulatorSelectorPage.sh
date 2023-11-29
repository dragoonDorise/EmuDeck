#!/bin/bash


setSetting doInstallRA false
setSetting doInstallDolphin false
setSetting doInstallPCSX2 false
setSetting doInstallCitra false
setSetting doInstallDuck false
setSetting doInstallPPSSPP false
setSetting doInstallSkyline false
setSetting doInstallDrastic false
setSetting doInstallMupen false
setSetting doInstallRedDream false
setSetting doInstallYaba false

case $devicePower in
0)		
		emulators=$(whiptail --title "Install emulators" \
	   --checklist "We have selected the recommended emulators for your device" 14 80 4 \
		"RA" "RetroArch - Classic 2D and 3D Games" ON \
		"DOLPHIN" "Dolphin - GameCube and Wii" ON \
		"DUCK" "Duckstation - Playstation 1" ON \
		"AETHERSX2" "AetherSX2 - Playstation 2" OFF \
		"CITRA" "Citra - Nintendo 3DS" OFF \
		"PPSSPP" "PPSSPP - Sony PSP" ON \
		"SKYLINE" "PPSSPP - Nintendo Switch" OFF \
		"YABA" "Saturn - Yaba Sanshiro" ON \
		"REDDREAM" "RedDream - Dreamcast" ON \
		"DRASTIC" "Drastic - Nintendo DS" ON \
		"MUPEN" "Mupen - Nintendo 64" OFF \
	   3>&1 1<&2 2>&3)
	
;;
1)	
		emulators=$(whiptail --title "Install emulators" \
	   --checklist "We have selected the recommended emulators for your device" 14 80 4 \
		"RA" "RetroArch - Classic 2D and 3D Games" ON \
		"DOLPHIN" "Dolphin - GameCube and Wii" ON \
		"DUCK" "Duckstation - Playstation 1" ON \
		"AETHERSX2" "AetherSX2 - Playstation 2" ON \
		"CITRA" "Citra - Nintendo 3DS" ON \
		"PPSSPP" "PPSSPP - Sony PSP" ON \
		"SKYLINE" "PPSSPP - Nintendo Switch" OFF \
		"YABA" "Saturn - Yaba Sanshiro" OFF \
		"REDDREAM" "RedDream - Dreamcast" OFF \
		"DRASTIC" "Drastic - Nintendo DS" ON \
		"MUPEN" "Mupen - Nintendo 64" OFF \
	   3>&1 1<&2 2>&3)
	
;;
2)
		
		emulators=$(whiptail --title "Install emulators" \
	   --checklist "We have selected the recommended emulators for your device" 14 80 4 \
		"RA" "RetroArch - Classic 2D and 3D Games" ON \
		"DOLPHIN" "Dolphin - GameCube and Wii" ON \
		"DUCK" "Duckstation - Playstation 1" ON \
		"AETHERSX2" "AetherSX2 - Playstation 2" ON \
		"CITRA" "Citra - Nintendo 3DS" ON \
		"PPSSPP" "PPSSPP - Sony PSP" ON \
		"SKYLINE" "PPSSPP - Nintendo Switch" ON \
		"YABA" "Saturn - Yaba Sanshiro" ON \
		"REDDREAM" "RedDream - Dreamcast" OFF \
		"DRASTIC" "Drastic - Nintendo DS" ON \
		"MUPEN" "Mupen - Nintendo 64" OFF \
	   3>&1 1<&2 2>&3)
	
;;
*)
	echo "no power"
;;
esac

mapfile -t settingsEmus <<< $emulators

for settingsEmu in "${settingsEmus[@]}";
 do
 	if [[ $settingsEmu == *"RA"* ]]; then
		setSetting doInstallRA true
	fi
	if [[ $settingsEmu == *"DOLPHIN"* ]]; then
		setSetting doInstallDolphin true
	fi
	if [[ $settingsEmu == *"DUCK"* ]]; then
		setSetting doInstallDuck true
	fi
	if [[ $settingsEmu == *"AETHERSX2"* ]]; then
		setSetting doInstallPCSX2 true
	fi
	if [[ $settingsEmu == *"CITRA"* ]]; then
		setSetting doInstallCitra true
	fi
	if [[ $settingsEmu == *"PPSSPP"* ]]; then
		setSetting doInstallPPSSPP true
	fi
	if [[ $settingsEmu == *"SKYLINE"* ]]; then
		setSetting doInstallSkyline true
	fi	
 done