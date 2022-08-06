#!/bin/bash
setMSG(){		
	progressBar=$((progressBar + 5))
	#We prevent the zenity to close if we have too much MSG, the classic eternal 99%
	if [ $progressBar == 95 ]; then
		progressBar=90
	fi	
	echo "$progressBar" > ~/emudeck/msg.log	
	echo "# $1" >> ~/emudeck/msg.log
	echo "$1"
	sleep 0.5
}