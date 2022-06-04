#!/bin/bash
doMigrations(){



	##nonstandard##
	#Xemu files to storage
	if [ -f "$savesPath/xemu/xbox_hdd.qcow2" ] || [ -f "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2" ] ; then		
		mkdir -p "$storagePath/xemu"
		echo -e ""
		setMSG "Moving Xemu HDD and EEPROM to the Emulation/storage folder"			
		echo -e ""
		mv "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2" $storagePath/xemu
		mv "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/eeprom.bin" $storagePath/xemu

		flatpak override app.xemu.xemu --filesystem="$storagePath"xemu:rw --user

        rsync -av $savesPath/xemu $storagePath && rm -rf $savesPath/xemu/

        sed -i "s|$savesPath|${storagePath}|g" "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
	fi

	#RPCS3 files to storage
	if [ -d "$savesPath/rpcs3/dev_hdd0/savedata" ] || [ -d "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" ]; then	

    	echo -e ""
		setMSG "Moving rpcs3 HDD to the Emulation/storage folder"			
		echo -e ""

		mkdir -p "$storagePath/rpcs3" 
		rsync -av "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" "$storagePath"rpcs3/ && rm -rf "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0"
        rsync -av "$savesPath"rpcs3/dev_hdd0 "$storagePath"rpcs3/ && rm -rf "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0"
		#update config file for the new loc $(emulatorDir) is in the file. made this annoying.
		sed -i 's|$(EmulatorDir)dev_hdd0/|'$storagePath'/rpcs3/dev_hdd0/|g' $HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml 
        sed -i "'s|'$savesPath'/rpcs3/dev_hdd0/|'$storagePath'/rpcs3/dev_hdd0/|g'" $HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml
	fi


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


}