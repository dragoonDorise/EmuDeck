#!/bin/bash
while true; do
	question=$(whiptail --title "Choose your aspect ratio for your Classic Nintendo Systems" \
   --radiolist "Choose your aspect ratio for your Classic Nintendo Systems" 10 80 4 \
	"43" "4:3 Original TV Aspect Ratio" ON \
	"87" "8:7 Real SNES Internal resolution" OFF \
	"32" "3:2 Less black bars, but distorted. Not recommended" OFF \
   3>&1 1<&2 2>&3)
	case $question in
		[43]* ) break;;
		[87]* ) break;;
		[32]* ) break;;
		* ) echo "Please select your AR for Nintendo.";;
	esac
done


case $question in
	43)
		setSetting arSnes 43
	;;
	87)
		setSetting arSnes 87
	;;
	32)
		setSetting arSnes 32
	;;
	*)
		echo "default"
	;;
esac