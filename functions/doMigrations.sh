#!/bin/bash
doMigrations(){



	##nonstandard##
	#Xemu files to storage
	if [ ! -d "$storagePath/xemu" ]; then		
		mkdir -p "$storagePath/xemu"
		echo -e ""
		setMSG "Moving Xemu HDD and EEPROM to the Emulation/storage folder"			
		echo -e ""
		mv /home/deck/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2 $storagePath/xemu 
		mv /home/deck/.var/app/app.xemu.xemu/data/xemu/xemu/eeprom.bin $storagePath/xemu 	
		flatpak override app.xemu.xemu --filesystem="$storagePath"xemu:rw --user

        mv -f $savesPath/xemu/* $storagePath/xemu/

        sed -i "s|$savesPath|${storagePath}|g" ~/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml
	fi

	#RPCS3 files to storage
	if [ ! -d "$storagePath/rpcs3/dev_hdd0/savedata" ] && [ -d "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" ]; then	
		if [ $destination != "$home" ]; then
			text="$(printf "Moving rpcs3 hdd0 to the Emulation/Saves folder\n\nDepending on how many pkgs you have installed, this may take a while.<b>If you do not have enough available space in your chosen location this will fail, clean up your SD Card and run EmuDeck Again.</b>")"
		else	
			text="$(printf "Moving rpcs3 hdd0 to the Emulation/Saves folder\n\nDepending on how many pkgs you have installed, this may take a while.")"
		fi
	
		mkdir -p "$storagePath/rpcs3" 
		rsync -r ~/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0 "$storagePath"/rpcs3/ && rm -rf ~/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0 
		#update config file for the new loc $(emulatorDir) is in the file. made this annoying.
		sed -i "'s|$(EmulatorDir)dev_hdd0/|'$storagePath'/rpcs3/dev_hdd0/|g'" /home/deck/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml 
        sed -i "'s|'$savesPath'/rpcs3/dev_hdd0/|'$storagePath'/rpcs3/dev_hdd0/|g'" /home/deck/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml
	fi


    #yuzu flatpak to appimage
    emu="Yuzu"
    #From -- > to
    migrationTable=()
    migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/data/yuzu" "$HOME/.local/share/yuzu")
    migrationTable+=("$HOME/.var/app/org.yuzu_emu.yuzu/config/yuzu" "$HOME/.config/yuzu")

    migrateAndLinkConfig $emu $migrationTable


}