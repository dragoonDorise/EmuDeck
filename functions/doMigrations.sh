#!/bin/bash
doMigrations(){

	##nonstandard##
	#Xemu files to storage if we have a xemu app folder
	if [ ! -f "$storagePath/xemu/xbox_hdd.qcow2" ] && [ -d "$HOME/.var/app/app.xemu.xemu" ]; then 

		echo "xbox hdd does not exist in storagepath."
		mkdir -p "$storagePath/xemu"
		flatpak override app.xemu.xemu --filesystem="$storagePath"xemu:rw --user

		xemuConf="$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
		xemuHDDLine="hdd_path = '${storagePath}xemu/xbox_hdd.qcow2'"
		xemuEEPLine="eeprom_path = '${storagePath}xemu/eeprom.bin'"
		sed -i "/hdd_path/c\\${xemuHDDLine}" $xemuConf
		sed -i "/eeprom_path/c\\${xemuEEPLine}" $xemuConf

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

	#RPCS3 files to storage
	#moved to setupStorageRpcs3

	emu="Yuzu"
	migrationFlag="$HOME/emudeck/.${emu}MigrationCompleted"
	#check if we have a nomigrateflag for $emu
	if [ ! -f "$migrationFlag" ]; then	
		#yuzu flatpak to appimage
		#From -- > to
		migrationTable=()
		migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu" "$HOME/.local/share/yuzu")
		migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/config/yuzu" "$HOME/.config/yuzu")

		migrateAndLinkConfig $emu $migrationTable
	fi

	#move data from hidden folders out to these folders in case the user already put stuff here.
	origPath="$HOME/.local/share/"

	mkdir -p ${storagePath}yuzu/dump
	mkdir -p ${storagePath}yuzu/load
	mkdir -p ${storagePath}yuzu/sdmc
	mkdir -p ${storagePath}yuzu/nand
	mkdir -p ${storagePath}yuzu/screenshots
	mkdir -p ${storagePath}yuzu/tas
	
	rsync -av ${origPath}yuzu/dump ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/dump
	rsync -av ${origPath}yuzu/load ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/load
	rsync -av ${origPath}yuzu/sdmc ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/sdmc
	rsync -av ${origPath}yuzu/nand ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/nand
	rsync -av ${origPath}yuzu/screenshots ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/screenshots
	rsync -av ${origPath}yuzu/tas ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/tas
	
}