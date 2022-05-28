#!/bin/bash
createSaveFolders(){		
	
	#RA
	if [ ! -d "$savesPath/retroarch/states" ]; then		
		mkdir -p $savesPath/retroarch
		echo -e ""
		echo -e "Linking RetroArch saved states to the Emulation/saves folder"			
		echo -e ""	
		mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch/states 
		ln -sn ~/.var/app/org.libretro.RetroArch/config/retroarch/states $savesPath/retroarch/states 
	fi
	if [ ! -d "$savesPath/retroarch/saves" ]; then	
		mkdir -p $savesPath/retroarch
		echo -e ""
		setMSG "Linking RetroArch saved games to the Emulation/saves folder"			
		echo -e ""
		mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch/saves 
		ln -sn ~/.var/app/org.libretro.RetroArch/config/retroarch/saves $savesPath/retroarch/saves 		
	fi
	
	#Dolphin
	if [ ! -d "$savesPath/dolphin/GC" ]; then	
		mkdir -p $savesPath/dolphin	
		echo -e ""
		setMSG "Linking Dolphin Gamecube saved games to the Emulation/saves folder"			
		echo -e ""	
		mkdir -p ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC
		ln -sn ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC $savesPath/dolphin/GC 
	fi
	if [ ! -d "$savesPath/dolphin/Wii" ]; then	
		mkdir -p $savesPath/dolphin	
		echo -e ""
		setMSG "Linking Dolphin Wii saved games to the Emulation/saves folder"			
		echo -e ""
		mkdir -p ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii	
		ln -sn ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii $savesPath/dolphin/Wii 
	fi
	if [ ! -d "$savesPath/dolphin/states" ]; then	
		mkdir -p $savesPath/dolphin	
		echo -e ""
		setMSG "Linking Dolphin States to the Emulation/saves folder"			
		echo -e ""
		mkdir -p ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves
		ln -sn ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves $savesPath/dolphin/states
	fi
	
	#PrimeHack
	if [ ! -d "$savesPath/primehack/GC" ]; then	
		mkdir -p $savesPath/primehack	
		echo -e ""
		setMSG "Linking PrimeHack Gamecube saved games to the Emulation/saves folder"			
		echo -e ""
		mkdir -p ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC
		ln -sn ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC $savesPath/primehack/GC
	fi
	if [ ! -d "$savesPath/primehack/Wii" ]; then	
		mkdir -p $savesPath/primehack	
		echo -e ""
		setMSG "Linking PrimeHack Wii saved games to the Emulation/saves folder"			
		echo -e ""
		mkdir -p ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii
		ln -sn ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii $savesPath/primehack/Wii	
	fi
	if [ ! -d "$savesPath/primehack/states" ]; then	
		mkdir -p $savesPath/primehack	
		echo -e ""
		setMSG "Linking PrimeHack States to the Emulation/states folder"			
		echo -e ""
		mkdir -p ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/StateSaves
		ln -sn ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/StateSaves $savesPath/primehack/states
	fi
	
	#Yuzu
	if [ ! -d "$savesPath/yuzu/saves" ]; then		
		mkdir -p $savesPath/yuzu
		echo -e ""
		setMSG "Linking Yuzu Saves to the Emulation/saves folder"			
		echo -e ""
		
		mkdir -p ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/sdmc
		ln -sn ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/sdmc $savesPath/yuzu/saves	
	fi
	
	#Duckstation
	if [ ! -d "$savesPath/duckstation/saves" ]; then		
		mkdir -p $savesPath/duckstation
		echo -e ""
		setMSG "Linking Duckstation Saves to the Emulation/saves folder"			
		echo -e ""
		mkdir -p ~/.var/app/org.duckstation.DuckStation/data/duckstation/memcards
		ln -sn ~/.var/app/org.duckstation.DuckStation/data/duckstation/memcards $savesPath/duckstation/saves	
	fi
	if [ ! -d "$savesPath/duckstation/states" ]; then	
		mkdir -p $savesPath/duckstation	
		echo -e ""
		setMSG "Linking Duckstation Saves to the Emulation/states folder"			
		echo -e ""
		mkdir -p ~/.var/app/org.duckstation.DuckStation/data/duckstation/savestates
		ln -sn ~/.var/app/org.duckstation.DuckStation/data/duckstation/savestates $savesPath/duckstation/states
	fi
	
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
	
	#PCSX2
	if [ ! -d "$savesPath/pcsx2/saves" ]; then		
		mkdir -p $savesPath/pcsx2
		echo -e ""
		setMSG "Linking PCSX2 Saves to the Emulation/saves folder"			
		echo -e ""	
		mkdir -p ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards
		ln -sn ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards $savesPath/pcsx2/saves
	fi
	if [ ! -d "$savesPath/pcsx2/states" ]; then	
		mkdir -p $savesPath/pcsx2	
		echo -e ""
		setMSG "Linking PCSX2 Saves to the Emulation/states folder"			
		echo -e ""	
		mkdir -p ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates
		ln -sn ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates $savesPath/pcsx2/states
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
	
	#Citra
	if [ ! -d "$savesPath/citra/saves" ]; then		
		mkdir -p $savesPath/citra
		echo -e ""
		setMSG "Linking Citra Saves to the Emulation/saves folder"			
		echo -e ""	
		mkdir -p ~/.var/app/org.citra_emu.citra/data/citra-emu/sdmc
		ln -sn ~/.var/app/org.citra_emu.citra/data/citra-emu/sdmc $savesPath/citra/saves
	fi
	if [ ! -d "$savesPath/citra/states" ]; then	
		mkdir -p $savesPath/citra	
		echo -e ""
		setMSG "Linking Citra Saves to the Emulation/states folder"			
		echo -e ""
		mkdir -p ~/.var/app/org.citra_emu.citra/data/citra-emu/states
		ln -sn ~/.var/app/org.citra_emu.citra/data/citra-emu/states $savesPath/citra/states
	fi
	#PPSSPP
	if [ ! -d "$savesPath/ppsspp/saves" ]; then		
		mkdir -p $savesPath/ppsspp
		echo -e ""
		setMSG "Linking PPSSPP Saves to the Emulation/saves folder"			
		echo -e ""
		mkdir -p ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA
		ln -sn ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA $savesPath/ppsspp/saves
	fi
	if [ ! -d "$savesPath/ppsspp/states" ]; then	
		mkdir -p $savesPath/ppsspp	
		echo -e ""
		setMSG "Linking PPSSPP Saves to the Emulation/states folder"			
		echo -e ""
		mkdir -p ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE
		ln -sn ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE $savesPath/ppsspp/states	
	fi
}