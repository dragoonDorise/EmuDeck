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
	fi 
	
}

#We rsync, only when rsync is completed we delete the old folder.
Migration_move(){
	target=$1
	destination=$2
	rsync -avzh --dry-run "$target" "$destination" && echo "true"
}