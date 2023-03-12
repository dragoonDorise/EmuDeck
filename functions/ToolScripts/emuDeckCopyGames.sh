#!/bin/bash
CreateStructureUSB(){
	destination=$1	
	mkdir -p "$destination/bios/"
	mkdir -p "$destination/roms/"
	rsync -rav --ignore-existing "$EMUDECKGIT/roms/" "$destination/roms/"|
	awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
	zenity --progress --title "Creating Rom Structure on $destination" \
	--text="Scanning..." --width=400 --percentage=0 --auto-kill
	
	text="`printf " <b>Folders created</b>\n\nEject your USB Drive and go to your computer and copy your roms to the folders created on $destination/roms/ and your bios on $destination/bios/)"`"
	 zenity --info \
			 --title="EmuDeck" \
			 --width="450" \
			 --text="${text}" 2>/dev/null && echo "true"			 
}

CopyGames(){
	origin=$1
	rsync -rav --ignore-existing --progress "$origin/roms" "$romsPath" |
	awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
	zenity --progress --title "Importing your games to $romsPath" \
	--text="Scanning..." --width=400 --percentage=0 --auto-kill
	
	rsync -rav --ignore-existing --progress "$origin/bios" "$biosPath" |
	awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
	zenity --progress --title "Importing your games to $biosPath" \
	--text="Scanning..." --width=400 --percentage=0 --auto-kill
}
