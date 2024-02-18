#!/bin/bash
source "$HOME/.config/EmuDeck/backend/functions/all.sh"

setMSG() {
	if [ -z $progressBar ]; then
		progressBar=0
	fi
	progressBar=$((progressBar + 5))

	# We prevent the zenity to close if we have too much MSG, the classic eternal 99%
	if [ $progressBar -eq 95 ]; then
		progressBar=90
	fi

	echo "$progressBar" > "$HOME/.config/EmuDeck/logs/msg.log"
	echo "# $1" >> "$HOME/.config/EmuDeck/logs/msg.log"
	echo "$1"
	sleep 0.5
}
