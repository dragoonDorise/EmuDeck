#!/bin/bash

#variables
emuName="cemu"
emuType="windows"
emuPath="${romsPath}wiiu/cemu.exe"
releaseURL="https://cemu.info/releases/cemu_1.26.2.zip"
cemuSettings="${romsPath}wiiu/settings.xml"

#cleanupOlderThings
Cemu.cleanup() {

}

#Install
Cemu.install() {
	setMSG "Installing Cemu"
	FILE="${romsPath}/wiiu/Cemu.exe"
	if [ -f "$FILE" ]; then
		echo "Cemu.exe already exists"
	else
		curl $releaseURL --output "$romsPath"wiiu/cemu.zip
		mkdir -p "$romsPath"wiiu/tmp
		unzip -o "$romsPath"wiiu/cemu.zip -d "$romsPath"wiiu/tmp
		mv "$romsPath"wiiu/tmp/cemu_*/ "$romsPath"wiiu/tmp/cemu/
		rsync -avzh "$romsPath"wiiu/tmp/cemu/ "$romsPath"wiiu/
		rm -rf "$romsPath"wiiu/tmp
		rm -f "$romsPath"wiiu/cemu.zip
	fi

	cp "$HOME/dragoonDoriseTools/EmuDeck/tools/launchers/cemu.sh" "${toolsPath}"launchers/cemu.sh
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|" "${toolsPath}"launchers/cemu.sh
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/wiiu|${romsPath}wiiu|" "${toolsPath}"launchers/cemu.sh
	chmod +x "${toolsPath}"launchers/cemu.sh
}

#ApplyInitialSettings
Cemu.init() {
	setMSG "Setting up Cemu"
	rsync -avhp "$HOME/dragoonDoriseTools/EmuDeck/configs/info.cemu.Cemu/data/cemu/" "${romsPath}wiiu"
	Cemu.setEmulationFolder
	Cemu.setupSaves
}

#update
Cemu.update() {
	setMSG "Updating Cemu Config"
	cemuSettings="${romsPath}wiiu/settings.xml"
	if [ -f $cemuSettings ]; then
		mv -f $cemuSettings $cemuSettings.bak #retain cemusettings if it exists to stop wiping peoples mods. Just insert our search path for installed games.
	fi
	rsync -avhp "$HOME/dragoonDoriseTools/EmuDeck/configs/info.cemu.Cemu/data/cemu/" "${romsPath}wiiu"
	rm $cemuSettings
	mv -f $cemuSettings.bak $cemuSettings
	Cemu.setEmulationFolder
	Cemu.setupSaves
}

#ConfigurePaths
Cemu.setEmulationFolder() {
	#cemuSettings="${romsPath}wiiu/settings.xml"
	if [[ -f "${cemuSettings}" ]]; then
		gamePathEntryFound=$(grep -rnw $cemuSettings -e "z:${romsPath}wiiu/roms")
		if [[ $gamePathEntryFound == '' ]]; then
			xmlstarlet ed --inplace --subnode "content/GamePaths" --type elem -n Entry -v "z:${romsPath}wiiu/roms" $cemuSettings
		fi
	fi
}

#SetupSaves
Cemu.setupSaves() {
	unlink "${savesPath}Cemu/saves" # Fix for previous bad symlink
	linkToSaveFolder Cemu saves "${romsPath}wiiu/mlc01/usr/save"
}

#SetupStorage
Cemu.setupStorage() {

}

#WipeSettings
Cemu.wipeSettings() {
	# rm -rf "${romPath}wiiu/"
	# prob not cause roms are here
}

#Uninstall
Cemu.uninstall() {
	rm -rf $emuPath
}

#setABXYstyle
Cemu.setABXYstyle() {

}

#Migrate
Cemu.migrate() {

}

#WideScreenOn
Cemu.wideScreenOn() {
	#na
}

#WideScreenOff
Cemu.wideScreenOff() {
	#na
}

#BezelOn
Cemu.bezelOn() {
	#na
}

#BezelOff
Cemu.bezelOff() {
	#na
}

#finalExec - Extra stuff
Cemu.finalize() {
	Cemu.cleanup
}
