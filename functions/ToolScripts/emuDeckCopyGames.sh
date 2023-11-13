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

	if [ $difference -lt 0 ]; then

		text="$(printf "Make sure you have enought space in $emulationPath. You need to have at least $neededSpaceInHuman available")"
		zenity --question \
			--title="EmuDeck Export tool" \
			--width=450 \
			--cancel-label="Exit" \
			--ok-label="Continue" \
			--text="${text}" 2>/dev/null
		ans=$?
		if [ $ans -eq 0 ]; then
			echo "Continue..."
		else
			exit
		fi
	fi




	(
	for entry in "$origin/roms"/*
	do
		if [ -d $entry ]; then
			files=$(find "$entry/" -type f ! -name "*.txt" | wc -l)
			if [ $files -gt 0 ]; then
				dir=$(basename "$entry")

				if [ $dir = "wiiu" ]; then
					entry="$entry/roms"
				fi

				if [ $dir = "xenia" ]; then
					entry="$entry/roms"
				fi

				rsync -rav --ignore-existing --progress --exclude=".*" "$entry/" "$romsPath/$dir/" |
				awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
				zenity --progress --title "Importing your $dir games to $romsPath" \
				--text="Scanning..." --width=400 --percentage=0 --auto-close
			fi
		 fi
	done

	rsync -rav --ignore-existing --progress "$origin/bios/" "$biosPath/" |
	awk -f $HOME/.config/EmuDeck/backend/rsync.awk |
	zenity --progress --title "Importing your games to $biosPath" \
	--text="Scanning..." --width=400 --percentage=0 --auto-close
	) &&
	text="`printf " <b>Success!</b>\n\nThe contents of your USB Drive have been copied to your Emulation folder)"`"
	 zenity --info \
			 --title="EmuDeck" \
			 --width="450" \
			 --text="${text}" 2>/dev/null && echo "true"

>>>>>>> 869765d3 (hotfixes import + migrate tools)

}
