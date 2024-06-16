#!/bin/bash

CheckUSB(){
	path=$(find /run/media/ -type d -name "EMUDECK" 2>/dev/null)
	if [ -n "$path" ]; then
	  echo $path
	else
	  echo "false"
	fi
}

CreateStructureUSB(){
	local destination=$1
	if [ -d "$destination/roms/" ]; then
		echo "Valid"
	else
		mkdir -p "$destination/bios/"
		mkdir -p "$destination/bios/dc"
		mkdir -p "$destination/roms/"

		echo  "# Where to put your bios?" > "$destination/bios/readme.txt"
		echo  "First of all, don't create any new subdirectory. ***" >> "$destination/bios/readme.txt"
		echo  "# System -> folder" > "$destination/bios/readme.txt"
		echo  "Playstation 1 / Duckstation -> bios/" >> "$destination/bios/readme.txt"
		echo  "Playstation 2 / PCSX2 -> bios/" >> "$destination/bios/readme.txt"
		echo  "Nintendo DS / melonDS -> bios/" >> "$destination/bios/readme.txt"
		echo  "Playstation 3 / RPCS3 -> Download it from https://www.playstation.com/en-us/support/hardware/ps3/system-software/" >> "$destination/bios/readme.txt"
		echo  "Dreamcast / RetroArch -> bios/dc" >> "$destination/bios/readme.txt"
		echo  "Switch / Yuzu -> bios/yuzu/firmware and bios/yuzu/keys" >> "$destination/bios/readme.txt"
		echo  "Those are the only mandatory bios, the rest are optional" >> "$destination/bios/readme.txt"

		rsync -ravL --ignore-existing --exclude='*.txt' "$EMUDECKGIT/roms/" "$destination/roms/" && echo "true" || echo "false"

	fi
}

AutoCopy_install(){
	cp "$EMUDECKGIT/tools/autocopy.sh" "$toolsPath/"

	chmod +x "$toolsPath/autocopy.sh"
}

AutoCopy(){
	local USBPath=$(CheckUSB)
	if [ -d $USBPath ];then
		local biosPathUSB="$USBPath/bios"
		if [ -d $biosPathUSB ];then
			CopyGames $USBPath
		else
			text="`printf "We are going to create the proper folder structure in your USB Drive"`"

			(
			  echo "3"; sleep 1
			  echo "2"; sleep 1
			  echo "1"; sleep 1
			) | zenity --progress --percentage=0 --auto-close --no-cancel \
					 --title="EmuDeck" \
					 --width="450" \
					 --text="${text}" 2>/dev/null
			CreateStructureUSB $USBPath
			text="`printf "<b>Success!</b>\n\nUSB folders created. Now copy your roms and bios in another computer and come back"`"
			(
			  echo "3"; sleep 1
			  echo "2"; sleep 1
			  echo "1"; sleep 1
			) |  zenity --progress --percentage=0 --auto-close --no-cancel \
					 --title="EmuDeck" \
					 --width="450" \
					 --text="${text}" 2>/dev/null
			if [ -d $biosPathUSB ];then
				CopyGames $USBPath
			fi
		fi
	else
		text="`printf "<b>Error!</b>\n\nUSB Drive not found.\n\nMake sure the drive is named EMUDECK, all caps"`"
		(
		  echo "3"; sleep 1
		  echo "2"; sleep 1
		  echo "1"; sleep 1
		) | zenity --progress --percentage=0 --auto-close --no-cancel \
				 --title="EmuDeck" \
				 --width="450" \
				 --text="${text}" 2>/dev/null
	fi
}

CopyGames(){
	local origin=$1

	local neededSpace=$(du -s "$origin" | awk '{print $1}')
	local neededSpaceInHuman=$(du -sh "$origin" | awk '{print $1}')

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
	zenity --progress --title "Importing your bios to $biosPath/" \
	--text="Scanning..." --width=400 --percentage=0 --auto-close
	) &&
	text="`printf " <b>Success!</b>\n\nThe contents of your USB Drive have been copied to your Emulation folder"`"
	(
	  echo "3"; sleep 1
	  echo "2"; sleep 1
	  echo "1"; sleep 1
	) | zenity  --progress --percentage=0 --auto-close --no-cancel \
			 --title="EmuDeck" \
			 --width="450" \
			 --text="${text}" 2>/dev/null && echo "true"

}
