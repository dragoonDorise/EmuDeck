#!/bin/bash
clear
if [ ! -f "$HOME/.config/EmuDeck/backend/functions/all.sh" ]; then
 text="$(printf "<b>EmuDeck installation not found</b>\nPlease Install EmuDeck before using this tool")"
 zenity --error \
	 --title="EmuDeck Import tool" \
	 --width=250 \
	 --ok-label="Bye" \
	 --text="${text}" 2>/dev/null
 exit
fi

. "$HOME/.config/EmuDeck/backend/functions/all.sh"

function checkSpace(){
	destination=$1
	neededSpace=$(du -s ./ | awk '{print $1}')
	neededSpaceInHuman=$(du -sh ./ | awk '{print $1}')
	#File Size on destination
	freeSpace=$(df -k "$destination" --output=avail | tail -1)
	freeSpaceInHuman=$(df -kh "$destination" --output=avail | tail -1)
	difference=$(($freeSpace - $neededSpace))

	if [[ $difference -lt 0 ]]; then
		text="$(printf "Make sure you have enought space in $destination. You need to have at least $neededSpaceInHuman available")"
		zenity --question \
			--title="EmuDeck Import tool" \
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

	else
		echo "Continue..."
	fi
}

text="$(printf "Welcome to EmuDeck's <b>import</b> save tool.\nThis script will help you migrate your EmuDeck saved games from another Steam Deck")"

zenity --question \
	--title="EmuDeck Import tool" \
	--width=450 \
	--cancel-label="Exit" \
	--ok-label="Import my saved games" \
	--text="${text}" 2>/dev/null
ans=$?
if [ $ans -eq 0 ]; then
	echo "Waiting for the user to pick a destination...."
else
	exit
fi

text="$(printf "Please select the drive where you have your <b>exported saves</b>")"
 zenity --info \
--title="EmuDeck Import tool" \
--width="${width}" \
--text="${text}" 2>/dev/null

origin=$(customLocation)
if [ -d "$origin/EmuDeck/saves/" ]; then
	echo "Continue..."
else
	text="$(printf "<b>No saved games detected</b>\nPlease select the root of the drive, don't select any of its folders.")"
	zenity --error \
	 --title="EmuDeck Import tool" \
	 --width=250 \
	 --ok-label="Try again" \
	 --text="${text}"

	 origin=$(customLocation)

	 if [ -d "$origin/EmuDeck/saves/" ]; then
		 echo "Continue..."
	 else
		 text="$(printf "<b>No EmuDeck save folder found</b>\nMake sure you have an Emulation/saves folder in your drive")"
		 zenity --error \
		  --title="EmuDeck Import tool" \
		  --width=250 \
		  --ok-label="Bye" \
		  --text="${text}"
	 fi
fi

checkSpace "$emulationPath"

for entry in "$origin/EmuDeck/saves/"*
do
	rsync -rav --ignore-existing --progress "$entry" "$emulationPath/saves/" | awk -f $HOME/.config/EmuDeck/backend/rsync.awk | zenity --progress --text="Importing $entry to $emulationPath/saves/" --title="Importing $entry..." --width=400 --percentage=0 --auto-close
done


size=0
for entry in "$emulationPath/saves/"*
do
	size=$((size + $(du -sb "$entry" | cut -f1)))
done


if [ "$size" -gt 4096 ]; then
	if [ -d "$origin/EmuDeck/storage" ]; then
		text="$(printf "<b>Storage folder found in your drive!</b>\nLet's import that one too")"
		zenity --question \
			--title="EmuDeck Import tool" \
			--width=450 \
			--cancel-label="Exit" \
			--ok-label="Import my storage" \
			--text="${text}" 2>/dev/null
		ans=$?
		if [ $ans -eq 0 ]; then

			checkSpace "$emulationPath"

			for entry in "$origin/EmuDeck/storage/"*
			do
				rsync -ravL --ignore-existing --progress "$entry" "$emulationPath/storage/" | awk -f $HOME/.config/EmuDeck/backend/rsync.awk | zenity --progress --text="Importing $entry to $emulationPath/storage/" --title="Importing $entry..." --width=400 --percentage=0 --auto-close
			done

		else
			exit
		fi

	fi

	text="$(printf "<b>Success!</b>\nRemember that you need to Open EmuDeck,run the USB Transfer Wizard and then Steam Rom Manager in this new device to add EmulationStation or any of your games")"
	 zenity --info \
	--title="EmuDeck Import tool" \
	--width=350 \
	--text="${text}"

else
	text="$(printf "<b>The operation failed</b>\nYour saved games might not have been exported.")"
	zenity --error \
	 --title="EmuDeck Import tool" \
	 --width=250 \
	 --ok-label="Bye" \
	 --text="${text}"

fi