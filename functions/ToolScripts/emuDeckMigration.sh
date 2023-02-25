#!/bin/bash
#variables

#We check the current Emulation folder space, and the destination
Migration_init(){
	destination=$1
	#File Size on target
	neededSpace=$(du -s "$emulationPath" | cut -f1)

	#File Size on destination
	freeSpace=$(df -k . | tail -1 | cut -d' ' -f6)
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
	rsync -avzh --dry-run "$origin" "$destination" && Migration_updatePaths "$origin" "$destination"
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
	sed -i "/${origin}/c\\${destination}" "$Cemu_cemuSettings"
	#Citra
	sed -i "/${origin}/c\\${destination}" "$Citra_configFile"
	#Dolphin
	sed -i "/${origin}/c\\${destination}" "$HOME/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini"
	#Duckstation
	sed -i "/${origin}/c\\${destination}" "$DuckStation_configFileNew"
	#Mame
	sed -i "/${origin}/c\\${destination}" "$MAME_configFile"
	#MelonDS
	sed -i "/${origin}/c\\${destination}" "$melonDS_configFile"
	#MGBA
	sed -i "/${origin}/c\\${destination}" "$mGBA_configFile"
	#PCSX2QT
	sed -i "/${origin}/c\\${destination}" "$PCSX2QT_configFile"
	#PPSSPP
	sed -i "/${origin}/c\\${destination}" "$HOME/.var/app/${PPSSPP_emuPath}/config/ppsspp/PSP/SYSTEM/ppsspp.ini"
	#Primehack
	sed -i "/${origin}/c\\${destination}" ""$HOME/.var/app/${Primehack_emuPath}/config/dolphin-emu/Dolphin.ini""
	#RetroArch
	sed -i "/${origin}/c\\${destination}" "$RetroArch_configFile"
	#RMG
	sed -i "/${origin}/c\\${destination}" "$RMG_configFile"
	#RPCS3
	sed -i "/${origin}/c\\${destination}" "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/vfs.yml"
	#Ryujinx
	sed -i "/${origin}/c\\${destination}" "$$HOME/.config/Ryujinx/Config.json"
	#ScummVM
	sed -i "/${origin}/c\\${destination}" "$ScummVM_configFile"
	#Vita3K
	sed -i "/${origin}/c\\${destination}" "$Vita3K_configFile"
	#Xemu
	sed -i "/${origin}/c\\${destination}" "$HOME/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
	#Xenia
	sed -i "/${origin}/c\\${destination}" "$Xenia_XeniaSettings"
	#Yuzu
	sed -i "/${origin}/c\\${destination}" "$HOME/.config/yuzu/qt-config.ini"
	
	#SRM
	shotcutsPath=$(find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vd")
	sed -i "/${origin}/c\\${destination}" "$shotcutsPath"
	
	
	text="$(printf "<b>Success</b>\nYour library has been moved to ${destination}")"	
    zenity --info \
		 --title="EmuDeck" \
		 --width=400 \
		 --text="${text}" 2>/dev/null	
}