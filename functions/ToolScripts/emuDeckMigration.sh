#!/bin/bash
#variables

#We check the current Emulation folder space, and the destination
Migration_init(){
	destination=$1
	#File Size on target
	neededSpace=$(du -s "$emulationPath" | awk '{print $1}')
	neededSpaceInHuman=$(du -sh "$emulationPath" | awk '{print $1}')

	#File Size on destination
	freeSpace=$(df -k $destination --output=avail | tail -1)
	freeSpaceInHuman=$(df -kh $destination --output=avail | tail -1)
	difference=$(($freeSpace - $neededSpace))
	if [ $difference -gt 0 ]; then
		Migration_move "$emulationPath" "$destination" "$neededSpaceInHuman" && Migration_updatePaths "$emulationPath" "$destination/Emulation/"
	else
		echo "abort"
		text="$(printf "<b>Not enough space</b>\nYou need to have at least ${neededSpaceInHuman} on ${destination}\nYou only have ${freeSpaceInHuman}")"
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
	size=$3
	rsync -av --progress "$origin" "$destination" |
	awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
	zenity --progress --title "Migrating your current ${size} Emulation folder to $destination" \
	--text="Scanning..." --width=400 --percentage=0 --auto-close	
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
	sed -i "s|${origin}|${destination}|g" "$HOME/.var/app/${Primehack_emuPath}/config/dolphin-emu/Dolphin.ini"
	#RetroArch
	sed -i "s|${origin}|${destination}|g" "$RetroArch_configFile"
	#RMG
	sed -i "s|${origin}|${destination}|g" "$RMG_configFile"
	#RPCS3
	sed -i "s|${origin}|${destination}|g" "$HOME/.var/app/${RPCS3_emuPath}/config/rpcs3/vfs.yml"
	#Ryujinx
	sed -i "s|${origin}|${destination}|g" "$HOME/.config/Ryujinx/Config.json"
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
		 
	echo "Valid"	 
}

#SRM path update for when 3.5 comes...
Migration_updateSRM(){
	origin=$1
	destination=$2		
	find "$HOME/.local/share/Steam/userdata" -name "shortcuts.vdf" -exec sed -i "s|${origin}|${destination}|g" {} +
}

Migration_updateParsers(){
	sed -i "s|${origin}|${destination}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"	
}

Migration_updateSettings(){
	sed -i "s|${origin}|${destination}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"	
}

Migration_ESDE(){
	ESDE_setEmulationFolder
}

Migration_fix_SDPaths(){
	
	if [ $(getSDPath) ]; then	
	
		newPath="$(getSDPath)"
		#emulationPath=/run/media/deck/FANCYGUIDTHATSWAYTOOLONG/gaming/emulation/ilovegames/Emulation
		oldPath=$(echo $emulationPath | grep -Po "^.*run\/[A-Za-z0-9]+\/[A-Za-z0-9]+\/[A-Za-z0-9]+")		
		firstString=$oldPath
		secondString=""
		oldPath="${firstString/Emulation/"$secondString"}" 
		
		text="$(printf "<b>Only use this if you have your roms on your SDCard and SteamOS 3.5 has been released and your Steam shortcuts no longer work.</b>\n\nYour old path was:\n${oldPath}\n\nYour new path is:\n${newPath}/\n\nDo you want me to change it?")"	
		zenity --question --title="Confirm path fix" --width 400 --text="${text}"  --ok-label="Yes" --cancel-label="No" 2>/dev/null
		if [[ $? == 0 ]]; then
			kill -15 $(pidof steam)
			Migration_updateSRM "$oldPath" "$newPath/" && Migration_updatePaths "$oldPath/Emulation" "$newPath/Emulation" && Migration_updateParsers "$oldPath" "$newPath/" &&  Migration_ESDE && echo "true"	
			 		
		fi	
	else
		text="`printf " <b>SD Card error</b>\n\nPlease check that your SD Card is properly inserted and recognized by SteamOS"`"
	 zenity --info \
			 --title="EmuDeck" \
			 --width="450" \
			 --text="${text}" 2>/dev/null	
	fi
}