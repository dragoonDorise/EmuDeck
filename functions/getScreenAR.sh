#!/bin/bash

getScreenAR(){	
	resolution=$(xrandr --current | grep 'primary' | uniq | awk '{print $4}'| cut -d '+' -f1)		
	Xaxis=$(echo $resolution | awk '{print $1}' | cut -d 'x' -f2)
	Yaxis=$(echo $resolution | awk '{print $1}' | cut -d 'x' -f1)		
	
	screenWidth=$Xaxis
	screenHeight=$Yaxis
	
	
	##Is rotated?
	if [ $Yaxis > $Xaxis ]; then
		screenWidth=$Yaxis
		screenHeight=$Xaxis		
	fi
	
	#echo $screenWidth
	#echo $screenHeight
	
	aspectRatio=$(awk -v screenWidth=$screenWidth -v screenHeight=$screenHeight 'BEGIN{printf "%.2f\n", (screenWidth/screenHeight)}')
	# 
	if [ $aspectRatio == 1.60 ]; then
		return=1610
	elif [ $aspectRatio == 1.78 ]; then
		return=169
	else
		return=0	
	fi
	echo $return
}