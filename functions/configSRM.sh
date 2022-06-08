#!/bin/bash
configSRM(){			
	setMSG "Configuring Steam Rom Manager..."
	mkdir -p ~/.config/steam-rom-manager/userData/
	cp ~/dragoonDoriseTools/EmuDeck/configs/steam-rom-manager/userData/userConfigurations.json ~/.config/steam-rom-manager/userData/userConfigurations.json
	sleep 3
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.config/steam-rom-manager/userData/userConfigurations.json
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" ~/.config/steam-rom-manager/userData/userConfigurations.json
	sed -i "s|/run/media/mmcblk0p1/Emulation/storage/|${storagePath}|g" ~/.config/steam-rom-manager/userData/userConfigurations.json
	echo -e "OK!"
}