#!/bin/bash
#variables

#We check the current Emulation folder space, and the destination
Migration_init(){
	destination=$1
	#File Size on target
	neededSpace=$(du -s "$emulationPath" | cut -f1)

	#File Size on destination
	freeSpace=$(df -s "$destination" |  cut -d' ' -f8)
	difference=$(($freeSpace - $neededSpace))
	if [ $difference -gt 0 ]; then
		Migration_move "$emulationPath" "$destination"	
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
	rsync -avzh --dry-run "$origin" "$destination" && Migration_updatePaths $origin $destination

}


Migration_updatePaths(){
	origin=$1
	destination=$2
	text="$(printf "<b>Success</b>\nYour library has been moved to ${destination}")"		
	
	#New settings
	setSetting emulationPath "${origin}Emulation"
	setSetting toolsPath "${origin}Emulation/tools"
	setSetting romsPath "${origin}Emulation/roms"
	setSetting biosPath "${origin}Emulation/bios"
	setSetting savesPath "${origin}Emulation/saves"
	setSetting storagePath "${origin}Emulation/storage"
	setSetting ESDEscrapData "${origin}Emulation/tools/downloaded_media"

	#Emu configs
	#Redo all inits?	
	# Cemu_init && Citra_init && Dolphin_init && ....
	
	
    zenity --info \
		 --title="EmuDeck" \
		 --width=400 \
		 --text="${text}" 2>/dev/null	
}