#!/bin/bash
# clear
# echo -e "Using Launchbox GamesDB..."
# for device_name in $romsPath/*;
#  do
# 	 message=$device_name
# 	 system="${message//'"'/}"
# 	 #ls $romsPath/$system
# 	 mkdir $romsPath/$system/media &> /dev/null
# 	 mkdir $romsPath/$system/media/screenshot &> /dev/null
# 	 mkdir $romsPath/$system/media/box2dfront &> /dev/null
# 	 mkdir $romsPath/$system/media/wheel &> /dev/null
#
# 	#Roms loop
# 	  for entry in $romsPath/$system/*
# 	  do
# 		  #Cleaning up names
# 		 firstString=$entry
# 		 secondString=""
# 		 romName="${firstString/"$romsPath/$system/"/"$secondString"}"
# 		 romNameNoExtension=${romName%.*}
#
# 		 startcapture=true
#
# 		 #.txt validation
# 		  STR=$romName
# 		  SUB='.txt'
# 		  if grep -q "$SUB" <<< "$STR"; then
# 			  startcapture=false
# 		  fi
# 		 #.sav validation
# 		  STR=$romName
# 		  SUB='.sav'
# 		  if grep -q "$SUB" <<< "$STR"; then
# 			  startcapture=false
# 		  fi
# 		#.srm validation
# 		 STR=$romName
# 		 SUB='.srm'
# 		 if grep -q "$SUB" <<< "$STR"; then
# 			 startcapture=false
# 		 fi
#
# 		 #Directory Validation
# 		 DIR=$romsPath/$system/$romName
# 		 if [ -d "$DIR" ]; then
# 			 startcapture=false
# 		 fi
#
# 		 #Blanks cleaning up, TODO: DRY
# 		 firstString=$romNameNoExtension
# 		 secondString=""
# 		 romNameNoExtensionNoDisc="${firstString/"Disc "/""}"
# 		 firstString=$romNameNoExtensionNoDisc
# 		 romNameNoExtensionNoRev="${firstString/"Rev "/""}"
# 		 firstString=$romNameNoExtensionNoRev
# 		 romNameNoExtensionTrimmed=$(echo $firstString | sed -r "s/(.[()].*)//g")
# 		 firstString=$romNameNoExtensionTrimmed
# 		 romNameNoExtensionNoAnd="${firstString/"&"/"$secondString"}"
# 		 firstString=$romNameNoExtensionNoAnd
# 		 secondString="%20"
# 		 romNameNoExtensionNoDash="${firstString/" - "/"$secondString"}"
# 		 firstString=$romNameNoExtensionNoDash
# 		 romNameNoExtensionNoDash="${firstString/"-"/"$secondString"}"
# 		 firstString=$romNameNoExtensionNoDash
# 		 romNameNoExtensionNoSpace="${firstString//" "/"$secondString"}"
# 		 firstString=$romNameNoExtensionNoSpace
# 		 secondString=""
# 		 romNameNoExtensionNoNkit="${firstString/".nkit"/"$secondString"}"
# 		 firstString=$romNameNoExtensionNoNkit
# 		 romNameNoExtensionNoSpace="${firstString/"!"/"$secondString"}"
# 		 firstString=$romNameNoExtensionNoSpace
#
# 		STR=$romNameNoExtensionTrimmed
# 		SUB=', The'
# 		if [[ "$STR" == *"$SUB"* ]]; then
#
# 			 firstString=$romNameNoExtensionTrimmed
# 			 secondString=""
# 			 romNameNoExtensionNoThe="${firstString/", The"/"$secondString"}"
#
# 			 romNameNoExtensionForLaunchbox="The $romNameNoExtensionNoThe"
#
# 			   else
# 			 romNameNoExtensionForLaunchbox=$romNameNoExtensionTrimmed
#
# 		fi
#
# 		romNameNoExtensionForLaunchbox=$(echo $romNameNoExtensionForLaunchbox | sed -r "s/,//g")
#
# 		 if [ $startcapture == true ]; then
#
# 			 hasWheel=false
# 			 hasSs=false
# 			 hasBox=false
#
# 			FILE=$romsPath/$system/media/wheel/$romNameNoExtension.png
# 			if [ -f "$FILE" ]; then
# 				 hasWheel=true
# 			fi
#
# 			FILE=$romsPath/$system/media/screenshot/$romNameNoExtension.png
# 			if [ -f "$FILE" ]; then
# 				 hasSs=true
# 			fi
#
# 			FILE=$romsPath/$system/media/box2dfront/$romNameNoExtension.png
# 			if [ -f "$FILE" ]; then
# 				 hasBox=true
# 			fi
#
# 			 #We only search games with no art
# 			 if [ $hasWheel == false ] || [ $hasSs == false ] || [ $hasBox == false ]; then
#
# 				content=$(cat ~/dragoonDoriseTools/pegasus-android-metadata/metadata.json)
#
# 				urlMediaWheel=$( jq -r  ".platform.$system.games.\"$romNameNoExtensionForLaunchbox\".medias.wheel" <<< "${content}" )
# 				urlMediaSs=$( jq -r  ".platform.$system.games.\"$romNameNoExtensionForLaunchbox\".medias.screenshot" <<< "${content}" )
# 				urlMediaBox=$( jq -r  ".platform.$system.games.\"$romNameNoExtensionForLaunchbox\".medias.box2dfront" <<< "${content}" )
#
# 				wheelSavePath="./storage/$romsPath/$system/media/wheel/$romNameNoExtension.png"
# 				ssSavePath="./storage/$romsPath/$system/media/screenshot/$romNameNoExtension.png"
# 				box2dfrontSavePath="./storage/$romsPath/$system/media/box2dfront/$romNameNoExtension.png"
#
# 				echo -e "Searching Images for $romNameNoExtension"
#
# 				if [[ $urlMediaWheel != null ]]; then
#
# 					if [ $hasWheel == true ]; then
# 						echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
# 					else
# 						wget -q --show-progress "$urlMediaWheel" -O "$wheelSavePath"
# 					fi
#
# 				fi
# 				if [[ $urlMediaSs != null ]]; then
# 					if [ $hasSs == true ]; then
# 						echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
# 					else
# 						wget -q --show-progress "$urlMediaSs" -O "$ssSavePath"
# 					fi
# 				fi
# 				if [[ $urlMediaBox != null ]]; then
# 					if [ $hasBox == true ]; then
# 						echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
# 					else
# 						wget -q --show-progress "$urlMediaBox" -O "$box2dfrontSavePath"
# 					fi
# 				fi
#
#
#
# 			else
# 				echo -e "Game already scraped" &> /dev/null
# 			fi
# 		 fi
# 	  done
#  done
#
# echo -e "${GREEN}completed${NONE}"