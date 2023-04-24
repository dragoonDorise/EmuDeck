#!/bin/bash
#variables
Xemu_emuName="Xemu-Emu"
Xemu_emuType="FlatPak"
Xemu_emuPath="app.xemu.xemu"

#cleanupOlderThings
Xemu_cleanup(){
 echo "NYI"
}

#Install
Xemu_install() {
	installEmuFP "${Xemu_emuName}" "${Xemu_emuPath}"
	flatpak override "${Xemu_emuPath}" --filesystem=host --user
}

#ApplyInitialSettings
Xemu_init() {
	configEmuFP "${Xemu_emuName}" "${Xemu_emuPath}" "true"
	Xemu_migrate
	Xemu_setupStorage
	Xemu_setEmulationFolder
}

#update
Xemu_update() {
	configEmuFP "${Xemu_emuName}" "${Xemu_emuPath}"
	Xemu_migrate
	Xemu_setupStorage
	Xemu_setEmulationFolder
}

#ConfigurePaths
Xemu_setEmulationFolder(){
  	configFile="$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"

    bootrrom_path='bootrom_path = '
	flashrom_path='flashrom_path = '
	eeprom_path='eeprom_path = '
	hdd_path='hdd_path = '

    bootrrom_pathSetting="${bootrrom_path}""'${biosPath}/mcpx_1.0.bin'"
	flashrom_pathSetting="${flashrom_path}""'${biosPath}/Complex_4627v1.03.bin'"
	eeprom_pathSetting="${eeprom_path}""'${storagePath}/xemu/eeprom.bin'"
	hdd_pathSetting="${hdd_path}""'${storagePath}/xemu/xbox_hdd.qcow2'"

    changeLine "${bootrrom_path}" "${bootrrom_pathSetting}" "$configFile"
    changeLine "${flashrom_path}" "${flashrom_pathSetting}" "$configFile"
    changeLine "${eeprom_path}" "${eeprom_pathSetting}" "$configFile"
    changeLine "${hdd_path}" "${hdd_pathSetting}" "$configFile"
}

#SetupSaves
Xemu_setupSaves(){
	echo "NYI"
}


#SetupStorage
Xemu_setupStorage(){
	mkdir -p "${storagePath}/xemu"
	flatpak override app.xemu.xemu --filesystem="${storagePath}/xemu":rw --user
	if [[ ! -f "${storagePath}/xemu/xbox_hdd.qcow2" ]]; then
		mkdir -p "${storagePath}/xemu"
		cd "${storagePath}/xemu"
		curl -L https://github.com/mborgerson/xemu-hdd-image/releases/latest/download/xbox_hdd.qcow2.zip -o xbox_hdd.qcow2.zip && unzip -j xbox_hdd.qcow2.zip && rm -rf xbox_hdd.qcow2.zip
	fi
}


#WipeSettings
Xemu_wipe() {
	rm -rf "$HOME/.var/app/$Xemu_emuPath"
	# prob not cause roms are here
}


#Uninstall
Xemu_uninstall() {
	flatpak uninstall "$Xemu_emuPath" --user -y
}

#setABXYstyle
Xemu_setABXYstyle(){
    	echo "NYI"
}

#Migrate
Xemu_migrate(){
    if [ ! -f "$storagePath/xemu/xbox_hdd.qcow2" ] && [ -d "$HOME/.var/app/app.xemu.xemu" ]; then 

		echo "xbox hdd does not exist in storagepath."
		echo -e ""
		setMSG "Moving Xemu HDD and EEPROM to the Emulation/storage folder"			
		echo -e ""
		
		if [ -f "${savesPath}/xemu/xbox_hdd.qcow2" ]; then
			mv -fv ${savesPath}/xemu/* ${storagePath}/xemu/ && rm -rf ${savesPath}/xemu/

		elif [ -f "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2" ]; then
			mv "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2" $storagePath/xemu/
			mv "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/eeprom.bin" $storagePath/xemu/

		fi
	fi
}

#WideScreenOn
Xemu_wideScreenOn(){
	configFile="$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
    fit='fit = '
    fitSetting="${fit}'scale_16_9'"
    changeLine "${fit}" "${fitSetting}" "$configFile"
}

#WideScreenOff
Xemu_wideScreenOff(){
	configFile="$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
    fit='fit = '
    fitSetting="${fit}'scale_4_3'"
    changeLine "${fit}" "${fitSetting}" "$configFile"
}

#BezelOn
Xemu_bezelOn(){
echo "NYI"
}

#BezelOff
Xemu_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Xemu_finalize(){
	echo "NYI"
}

Xemu_IsInstalled(){
	isFpInstalled "$Xemu_emuPath"
}

Xemu_resetConfig(){
	Xemu_init &>/dev/null && echo "true" || echo "false"
}