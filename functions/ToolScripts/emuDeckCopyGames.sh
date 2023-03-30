#!/bin/bash
CreateStructureUSB(){
	destination=$1	
	mkdir -p "$destination/bios/"
	mkdir -p "$destination/roms/"
	rsync -rav --ignore-existing "$EMUDECKGIT/roms/" "$destination/roms/"|
	awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
	zenity --progress --title "Creating Rom Structure on $destination" \
	--text="Scanning..." --width=400 --percentage=0 --auto-close
	
	text="`printf " <b>Folders created</b>\n\nEject your USB Drive and go to your computer and copy your roms to the folders created on $destination/roms/ and your bios on $destination/bios/)"`"
	 zenity --info \
			 --title="EmuDeck" \
			 --width="450" \
			 --text="${text}" 2>/dev/null && echo "true"			 
}

CopyGames(){
	origin=$1
	
	neededSpace=$(du -s "$origin" | cut -f1)
	neededSpaceInHuman=$(du -sh "$origin" | cut -f1)
	
	#File Size on destination
	freeSpace=$(df -k $emulationPath | tail -1 | cut -d' ' -f6)
	freeSpaceInHuman=$(df -kh $emulationPath | tail -1 | cut -d' ' -f10)
	difference=$(($freeSpace - $neededSpace))

	if [ $difference -gt 0 ]; then
		rsync -rav --ignore-existing --progress "$origin/roms/" "$romsPath/" |
		awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
		zenity --progress --title "Importing your games to $romsPath" \
		--text="Scanning..." --width=400 --percentage=0 --auto-close
		
		rsync -rav --ignore-existing --progress "$origin/bios/" "$biosPath/" |
		awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
		zenity --progress --title "Importing your games to $biosPath" \
		--text="Scanning..." --width=400 --percentage=0 --auto-close
	else
		text="$(printf "<b>Not enough space</b>\nYou need to have at least ${neededSpaceInHuman} on ${emulationPath}\nYou only have ${freeSpaceInHuman}")"
		 zenity --error \
				 --title="EmuDeck" \
				 --width=400 \
				 --text="${text}" 2>/dev/null		
	fi 
	

}
