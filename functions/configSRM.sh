#!/bin/bash
configSRM() {
	setMSG "Configuring Steam Rom Manager..."
	mkdir -p "$HOME/.config/steam-rom-manager/userData/"
	SRM_CONFIG_FILE="$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
	cp "$HOME/dragoonDoriseTools/EmuDeck/configs/steam-rom-manager/userData/userConfigurations.json" "$SRM_CONFIG_FILE"
	sleep 3
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" "$SRM_CONFIG_FILE"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" "$SRM_CONFIG_FILE"
	sed -i "s|/run/media/mmcblk0p1/Emulation/storage/|${storagePath}|g" "$SRM_CONFIG_FILE"
	echo -e "OK!"
}
