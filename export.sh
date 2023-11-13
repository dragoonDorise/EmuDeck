#!/bin/bash
clear
if [ ! -f "$HOME/.config/EmuDeck/backend/functions/all.sh" ]; then
 text="$(printf "<b>EmuDeck installation not found</b>")"
 zenity --error \
	 --title="EmuDeck Export tool" \
	 --width=250 \
	 --ok-label="Bye" \
	 --text="${text}" 2>/dev/null
 exit
fi
. "$HOME/.config/EmuDeck/backend/functions/all.sh"

function checkSpace(){
	destination=$1
	neededSpace=$(du -s "$emulationPath/saves" | awk '{print $1}')
	neededSpaceInHuman=$(du -sh "$emulationPath/saves" | awk '{print $1}')
	#File Size on destination
	freeSpace=$(df -k "$destination" --output=avail | tail -1)
	freeSpaceInHuman=$(df -kh "$destination" --output=avail | tail -1)
	difference=$(($freeSpace - $neededSpace))

	if [[ $difference -lt 0 ]]; then
		text="$(printf "Make sure you have enought space in $destination. You need to have at least $neededSpaceInHuman available")"
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

	else
		echo "Continue..."
	fi
}

text="$(printf "Welcome to EmuDeck's <b>export</b> tool.\nThis script will help you migrate your EmuDeck saved games to another Steam Deck")"

zenity --question \
	--title="EmuDeck Export tool" \
	--width=450 \
	--cancel-label="Exit" \
	--ok-label="Export my saved games" \
	--text="${text}" 2>/dev/null
ans=$?
if [ $ans -eq 0 ]; then
	echo "Waiting for the user to pick a destination...."
else
	exit
fi

text="$(printf "Please pick where do you want to <b>export your saves</b>")"
 zenity --info \
--title="EmuDeck Export tool" \
--width="${width}" \
--text="${text}" 2>/dev/null

destination=$(customLocation)
checkSpace "$destination"

mkdir -p "$destination/EmuDeck/saves"

for entry in "$emulationPath/saves/"*
do
	rsync -ravL --ignore-existing --progress "$entry" "$destination/EmuDeck/saves/" | awk -f $HOME/.config/EmuDeck/backend/rsync.awk | zenity --progress --text="Exporting $entry to $destination/EmuDeck/saves/" --title="Exporting $entry..." --width=400 --percentage=0 --auto-close
done


size=0
for entry in "$emulationPath/saves/"*
do
	size=$((size + $(du -sb "$entry" | cut -f1)))
done


if [ "$size" -gt 4096 ]; then
	if [ -d "$HOME/Emulation/storage" ]; then
		text="$(printf "<b>Storage folder found in your internal Drive!</b>\nLet's export that one too")"
		zenity --question \
			--title="EmuDeck Export tool" \
			--width=450 \
			--cancel-label="Exit" \
			--ok-label="Export my storage" \
			--text="${text}" 2>/dev/null
		ans=$?
		if [ $ans -eq 0 ]; then

			checkSpace "$destination"

			mkdir -p "$destination/EmuDeck/storage"

			for entry in "$emulationPath/storage/"*
			do
				rsync -ravL --ignore-existing --progress "$entry" "$destination/EmuDeck/storage/" | awk -f $HOME/.config/EmuDeck/backend/rsync.awk | zenity --progress --text="Exporting $entry to $destination/EmuDeck/storage/" --title="Exporting $entry..." --width=400 --percentage=0 --auto-close
			done

		else
			exit
		fi

	fi

	text="$(printf "<b>Success!</b>\nNow it's time to:\n1 Install EmuDeck in your new Deck. \n2 Use the Import Tool in your new Deck. \n3 That's all :)")"
	 zenity --info \
	--title="EmuDeck Export tool" \
	--width=350 \
	--text="${text}"

else
	text="$(printf "<b>The operation failed</b>\nYour saved games might not have been exported.")"
	zenity --error \
	 --title="EmuDeck Export tool" \
	 --width=250 \
	 --ok-label="Bye" \
	 --text="${text}"

fi