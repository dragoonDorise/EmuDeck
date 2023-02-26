#!/bin/bash
#variables

#We check the current Emulation folder space, and the destination
Migration_init(){
	destination=$1
	#File Size on target
	neededSpace=$(du -s "$emulationPath" | cut -f1)

	#File Size on destination
	freeSpace=$(df -k $destination | tail -1 | cut -d' ' -f6)
	difference=$(($freeSpace - $neededSpace))
	if [ $difference -gt 0 ]; then
		Migration_move "$emulationPath" "$destination/Emulation"	
	else
		text="$(printf "<b>Not enough space</b>\nYou need to have at least ${neededSpace} on ${destination}")"
		 zenity --error \
				 --title="EmuDeck" \
				 --width=400 \
				 --text="${text}" 2>/dev/null		
	fi 
	
}

#We rsync, only when rsync is completed we delete the old folder.
Migration_move(){
	origin=$1
	destination=$2
	mkdir -p "$destination"
	rsync --remove-source-files -avzh "$origin" "$destination" && Migration_updatePaths "$origin" "$destination"
}


Migration_updatePaths(){
	origin=$1
	destination=$2		
	
	#New settings
	setSetting emulationPath "${destination}"
	setSetting toolsPath "${destination}/tools"
	setSetting romsPath "${destination}/roms"
	setSetting biosPath "${destination}/bios"
	setSetting savesPath "${destination}/saves"
	setSetting storagePath "${destination}/storage"
	setSetting ESDEscrapData "${destination}/tools/downloaded_media"

	#Emu configs
	#Cemu
	sed -i "s|${origin}|${destination}|g" "$Cemu_cemuSettings"
	#Citra
	sed -i "s|${origin}|${destination}|g" "$Citra_configFile"
	#Dolphin
	sed -i "s|${origin}|${destination}|g" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini"
	#Duckstation
	sed -i "s|${origin}|${destination}|g" "$DuckStation_configFileNew"
	#Mame
	sed -i "s|${origin}|${destination}|g" "$MAME_configFile"
	#MelonDS
	sed -i "s|${origin}|${destination}|g" "$melonDS_configFile"
	#MGBA
	sed -i "s|${origin}|${destination}|g" "$mGBA_configFile"
	#PCSX2QT
	sed -i "s|${origin}|${destination}|g" "$PCSX2QT_configFile"
	#PPSSPP
	sed -i "s|${origin}|${destination}|g" "$HOME/.var/app/${PPSSPP_emuPath}/config/ppsspp/PSP/SYSTEM/ppsspp.ini"
	#Primehack
	sed -i "s|${origin}|${destination}|g" ""$HOME/.var/app/${Primehack_emuPath}/config/dolphin-emu/Dolphin.ini""
	#RetroArch
	sed -i "s|${origin}|${destination}|g" "$RetroArch_configFile"
	#RMG
	sed -i "s|${origin}|${destination}|g" "$RMG_configFile"
	#RPCS3
	sed -i "s|${origin}|${destination}|g" "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/vfs.yml"
	#Ryujinx
	sed -i "s|${origin}|${destination}|g" "$$HOME/.config/Ryujinx/Config.json"
	#ScummVM
	sed -i "s|${origin}|${destination}|g" "$ScummVM_configFile"
	#Vita3K
	sed -i "s|${origin}|${destination}|g" "$Vita3K_configFile"
	#Xemu
	sed -i "s|${origin}|${destination}|g" "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
	#Xenia
	sed -i "s|${origin}|${destination}|g" "$Xenia_XeniaSettings"
	#Yuzu
	sed -i "s|${origin}|${destination}|g" "$HOME/.config/yuzu/qt-config.ini"	
	#SRM
	Migration_updateSRM $origin $destination
	
	text="$(printf "<b>Success</b>\nYour library has been moved to ${destination}\nPlease restart your Deck now to apply the changes")"	
	zenity --info \
		 --title="EmuDeck" \
		 --width=400 \
		 --text="${text}" 2>/dev/null	
}

#SRM path update for when 3.5 comes...
Migration_updateSRM(){
	origin=$1
	destination=$2		
	find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vdf" -exec sed -i "s|${origin}|${destination}|g" {} +
}

Migration_fixSRMArgs(){
	#grep -Pa '\x00' --color=never shortcuts.vdf | cat -vET	
	firstSearch="/usr/bin\x00\x00LaunchOptions\x00\x00"
	firstReplace="/usr/bin\x00\x00"
	secondSearch='flatpak" run org.libretro.RetroArch'
	properLaunch="flatpak\"\x00\x00LaunchOptions\x00run org.libretro.RetroArch"
	
	#Cleanup LaunchOptions
	find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vdf" -exec sed -i "s|${firstSearch}|${firstReplace}|g" {} +
	
	#New LaunchOptions
	find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vdf" -exec sed -i "s|${secondSearch}|${properLaunch}|g" {} +
}






