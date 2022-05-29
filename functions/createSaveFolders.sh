#!/bin/bash
createSaveFolders(){		
	
	#linkToSaveFolder emuname foldername pathtolink

	#RA
	linkToSaveFolder retroarch states ~/.var/app/org.libretro.RetroArch/config/retroarch/states
	linkToSaveFolder retroarch saves ~/.var/app/org.libretro.RetroArch/config/retroarch/saves
	
	#Dolphin
	linkToSaveFolder dolphin GC ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC
	linkToSaveFolder dolphin Wii ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii
	linkToSaveFolder dolphin states ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/states
	
	#PrimeHack
	linkToSaveFolder primehack GC ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC
	linkToSaveFolder primehack Wii ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii
	linkToSaveFolder primehack states ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/states
	
	#Yuzu
	unlink $savesPath/yuzu/saves # Fix for previous bad symlink
	linkToSaveFolder yuzu saves ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/user/save/
	
	#Duckstation
	linkToSaveFolder duckstation saves ~/.var/app/org.duckstation.DuckStation/data/duckstation/memcards
	linkToSaveFolder duckstation states ~/.var/app/org.duckstation.DuckStation/data/duckstation/savestates
	
	#PCSX2
	linkToSaveFolder pcsx2 saves ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards
	linkToSaveFolder pcsx2 states ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates
	
	#Citra
	linkToSaveFolder citra saves ~/.var/app/org.citra_emu.citra/data/citra-emu/sdmc
	linkToSaveFolder citra states ~/.var/app/org.citra_emu.citra/data/citra-emu/states

	#PPSSPP
	linkToSaveFolder ppsspp saves ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA
	linkToSaveFolder ppsspp states ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE

	##nonstandard##
	#Xemu
	if [ ! -d "$savesPath/xemu" ]; then		
		mkdir -p "$savesPath/xemu"
		echo -e ""
		setMSG "Moving Xemu HDD and EEPROM to the Emulation/saves folder"			
		echo -e ""
		mv /home/deck/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2 $savesPath/xemu 
		mv /home/deck/.var/app/app.xemu.xemu/data/xemu/xemu/eeprom.bin $savesPath/xemu 	
		flatpak override app.xemu.xemu --filesystem="$savesPath"xemu:rw --user
	fi

	#RPCS3
	if [ ! -d "$savesPath/rpcs3/dev_hdd0/savedata" ] && [ -d "$HOME/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0" ]; then	
		if [ $destination != "$home" ]; then
			text="$(printf "Moving rpcs3 hdd0 to the Emulation/Saves folder\n\nDepending on how many pkgs you have installed, this may take a while.<b>If you do not have enough available space in your chosen location this will fail, clean up your SD Card and run EmuDeck Again.</b>")"
		else	
			text="$(printf "Moving rpcs3 hdd0 to the Emulation/Saves folder\n\nDepending on how many pkgs you have installed, this may take a while.")"
		fi
		zenity --info \
		--title="EmuDeck" \
		--width=450 \
		--text="${text}" 2>/dev/null
	
		mkdir -p "$savesPath/rpcs3" 
		rsync -r ~/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0 "$savesPath"/rpcs3/ && rm -rf ~/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0 
		#update config file for the new loc $(emulatorDir) is in the file. made this annoying.
		sed -i "'s|$(EmulatorDir)dev_hdd0/|'$savesPath'/rpcs3/dev_hdd0/|g'" /home/deck/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml 
	fi
}