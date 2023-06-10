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
	
	neededSpace=$(du -s "$origin" | awk '{print $1}')
	neededSpaceInHuman=$(du -sh "$origin" | awk '{print $1}')

	#File Size on destination
	freeSpace=$(df -k $emulationPath --output=avail | tail -1)
	freeSpaceInHuman=$(df -kh $emulationPath --output=avail | tail -1)
	difference=$(($freeSpace - $neededSpace))
	

	if [ $difference -gt 0 ]; then
		(
		rsync -rav --ignore-existing --progress --exclude=".*" "$origin/roms/" "$romsPath/" |
		awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
		zenity --progress --title "Importing your games to $romsPath" \
		--text="Scanning..." --width=400 --percentage=0 --auto-close
		
		rsync -rav --ignore-existing --progress --exclude=".*" "$origin/bios/" "$biosPath/" |
		awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
		zenity --progress --title "Importing your games to $biosPath" \
		--text="Scanning..." --width=400 --percentage=0 --auto-close
		) && 
		text="`printf " <b>Success!</b>\n\nThe contents of your USB Drive have been copied to your Emulation folder)"`"
		 zenity --info \
				 --title="EmuDeck" \
				 --width="450" \
				 --text="${text}" 2>/dev/null && echo "true"	
	else
		text="$(printf "<b>Not enough space</b>\nYou need to have at least ${neededSpaceInHuman} on ${emulationPath}\nYou only have ${freeSpaceInHuman}")"
		 zenity --error \
				 --title="EmuDeck" \
				 --width=400 \
				 --text="${text}" 2>/dev/null		
	fi 
	

}
