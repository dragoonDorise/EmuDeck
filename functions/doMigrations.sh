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
	if [ ! -d "$storagePath"rpcs3/dev_hdd0 ] && [ -d "$HOME/.var/app/net.rpcs3.RPCS3/" ];then
		echo "rpcs3 hdd does not exist in storagepath."
		#update config file for the new loc $(emulatorDir) is in the file. made this annoying.
		rpcs3VFSConf="$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml"
		rpcs3DevHDD0Line="/dev_hdd0/: ${storagePath}rpcs3/dev_hdd0/"
		sed -i "/dev_hdd0/c\\${rpcs3DevHDD0Line}" $rpcs3VFSConf 

		echo -e ""
		setMSG "Moving rpcs3 HDD to the Emulation/storage folder"			
		echo -e ""
		
		mkdir -p "$storagePath/rpcs3" 

		if [ -d "$savesPath/rpcs3/dev_hdd0" ]; then
			mv -f "$savesPath"rpcs3/dev_hdd0 "$storagePath"rpcs3/

		elif [ -d "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" ]; then	
			rsync -av "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" "$storagePath"rpcs3/ && rm -rf "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0"

		fi
	fi

	
	yuzuMigrationFlag="$HOME/emudeck/.yuzuMigrationCompleted"
	#check if we have a nomigrateflag for $emu
	if [ ! -f "$yuzuMigrationFlag" ]; then	
		#yuzu flatpak to appimage
		emu="Yuzu"
		#From -- > to
		migrationTable=()
		migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu" "$HOME/.local/share/yuzu")
		migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/config/yuzu" "$HOME/.config/yuzu")

		migrateAndLinkConfig $emu $migrationTable

		mkdir -p ${storagePath}yuzu/dump
		mkdir -p ${storagePath}yuzu/load
		mkdir -p ${storagePath}yuzu/sdmc
		mkdir -p ${storagePath}yuzu/nand
		mkdir -p ${storagePath}yuzu/screenshots
		mkdir -p ${storagePath}yuzu/tas

		#move data from hidden folders out to these folders in case the user already put stuff here.
		origPath="$HOME/.local/share/"
		rsync -av ${origPath}yuzu/dump ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/dump
		rsync -av ${origPath}yuzu/load ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/load
		rsync -av ${origPath}yuzu/sdmc ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/sdmc
		rsync -av ${origPath}yuzu/nand ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/nand
		rsync -av ${origPath}yuzu/screenshots ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/screenshots
		rsync -av ${origPath}yuzu/tas ${storagePath}yuzu/ && rm -rf ${origPath}yuzu/tas
	fi
}