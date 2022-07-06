#!/bin/bash

#variables
emuName="Xemu-Emu"
emuType="FlatPak"
emuPath="app.xemu.xemu"
releaseURL=""

#cleanupOlderThings
Xemu.cleanup() {
	#na
}

#Install
Xemu.install() {
	installEmuFP "${emuName}" "${emuPath}"
	flatpak override "${emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
Xemu.init() {
	configEmuFP "${emuName}" "${emuPath}" "true"
	Xemu.migrate
	Xemu.setupStorage
	Xemu.setEmulationFolder
	setupSavesXemu
}

#update
Xemu.update() {
	configEmuFP "${emuName}" "${emuPath}"
	Xemu.migrate
	Xemu.setupStorage
	Xemu.setEmulationFolder
	setupSavesXemu
}

#ConfigurePaths
Xemu.setEmulationFolder() {
	configFile="$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"

	bootrrom_path='bootrom_path = '
	flashrom_path='flashrom_path = '
	eeprom_path='eeprom_path = '
	hdd_path='hdd_path = '

	bootrrom_pathSetting="${bootrrom_path}""${biosPath}mcpx_1.0.bin"
	flashrom_pathSetting="${flashrom_path}""${biosPath}Complex_4627v1.03.bin"
	eeprom_pathSetting="${eeprom_path}""${storagePath}xemu/eeprom.bin"
	hdd_pathSetting="${hdd_path}""${storagePath}xemu/xbox_hdd.qcow2"

	sed -i "/${bootrrom_path}/c\\${bootrrom_pathSetting}" "$configFile"
	sed -i "/${flashrom_path}/c\\${flashrom_pathSetting}" "$configFile"
	sed -i "/${eeprom_path}/c\\${eeprom_pathSetting}" "$configFile"
	sed -i "/${hdd_path}/c\\${hdd_pathSetting}" "$configFile"
}

#SetupSaves
Xemu.setupSaves() {

}

#SetupStorage
Xemu.setupStorage() {
	mkdir -p "${storagePath}xemu"
	flatpak override app.xemu.xemu --filesystem="${storagePath}xemu":rw --user
	if [[ ! -f "${storagePath}xemu/xbox_hdd.qcow2" ]]; then
		mkdir -p "${storagePath}xemu"
		cd "${storagePath}xemu"
		curl -L https://github.com/mborgerson/xemu-hdd-image/releases/latest/download/xbox_hdd.qcow2.zip -o xbox_hdd.qcow2.zip && unzip -j xbox_hdd.qcow2.zip && rm -rf xbox_hdd.qcow2.zip
	fi
}

#WipeSettings
Xemu.wipe() {
	rm -rf "$HOME/.var/app/$emuPath"
	# prob not cause roms are here
}

#Uninstall
Xemu.uninstall() {
	flatpack uninstall "$emuPath" -y
}

#setABXYstyle
Xemu.setABXYstyle() {

}

#Migrate
Xemu.migrate() {
	if [ ! -f "$storagePath/xemu/xbox_hdd.qcow2" ] && [ -d "$HOME/.var/app/app.xemu.xemu" ]; then

		echo "xbox hdd does not exist in storagepath."
		echo -e ""
		setMSG "Moving Xemu HDD and EEPROM to the Emulation/storage folder"
		echo -e ""

		if [ -f "${savesPath}xemu/xbox_hdd.qcow2" ]; then
			mv -fv ${savesPath}xemu/* ${storagePath}xemu/ && rm -rf ${savesPath}xemu/

		elif [ -f "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2" ]; then
			mv "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2" $storagePath/xemu/
			mv "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/eeprom.bin" $storagePath/xemu/

		fi
	fi
}

#WideScreenOn
Xemu.wideScreenOn() {
	configFile="$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
	fit='fit = '
	fitSetting="${fit}""${fitSetting}scale_16_9"
	sed -i "/${fit}/c\\${fitSetting}" "$configFile"
}

#WideScreenOff
Xemu.wideScreenOf() {
	configFile="$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
	fit='fit = '
	fitSetting="${fit}""${fitSetting}scale_4_3"
	sed -i "/${fit}/c\\${fitSetting}" "$configFile"
}

#BezelOn
Xemu.bezelOn() {
	#na
}

#BezelOff
Xemu.bezelOff() {
	#na
}

#finalExec - Extra stuff
Xemu.finalize() {
	#na
}
