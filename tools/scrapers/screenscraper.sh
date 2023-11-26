#!/bin/bash

# if (whiptail --title "Scrape metadata" --yesno "Would you like to scrape metadata for individual games?" 8 78); then
# 	saveMetadata=true
# else
# 	saveMetadata=false
# fi
clear
echo -e "Using ScreenScraper..."

#We check for existing credentials
userStored=false
FILE="$HOME/emudeck/.screenScraperUser"
if [ -f "$FILE" ]; then
	userStored=true
	userSS=$(cat "$HOME/emudeck/.screenScraperUser")
	passSS=$(cat "$HOME/emudeck/.screenScraperPass")
fi

if [ $userStored == false ]; then

	if (whiptail --title "Screen Scraper" --yesno "Do you have an account on www.screenscraper.fr? If you don't we will open your browser so you can create one. Come back afterwards" 8 78); then
		find $HOME/shared/RetroArch/config/ -type f -name "*.cfg" -exec sed -i -e 's/input_overlay_enable = "false"/input_overlay_enable = "true"/g' {} \;
	else
		termux-open "https://www.screenscraper.fr/membreinscription.php"
		clear
		echo -e "Press the ${RED}A Button${NONE} if you already have your account created"
		read pause
	fi

	echo -e "Now I'm going to ask for your username and password. ${BOLD}These will never be read or used outside this scraper${NONE}"
	echo -e "What is your ScreenScraper user? Type it and press the ${RED}A button${NONE}"
	read user
	echo $user > ~/emudeck/.screenScraperUser
	echo -e "What is your ScreenScraper password? Type it and press the ${RED}A button${NONE}"
	read pass
	echo $pass > ~/emudeck/.screenScraperPass

	echo -e "${GREEN}Thanks!${NONE}"
	echo -e "You can change the credentials later by opening Termux again"
	echo -e "Press the ${RED}A Button${NONE} to start scraping your roms"
	read pause
fi

#ScreenScraper loop
for device_name in $romsPath/*;
do
	message=$device_name
	system="${message//'"'/}"
	mkdir $romsPath/$system/media &> /dev/null
	mkdir $romsPath/$system/media/screenshot &> /dev/null
	mkdir $romsPath/$system/media/box2dfront &> /dev/null
	mkdir $romsPath/$system/media/wheel &> /dev/null

	#ScreenScraper system ID
	get_sc_id $system
	echo ""
	echo -e "Scraping $system..."
	echo ""

	#Check for metadata file
	metadataFile=$romsPath/$system/metadata.pegasus.txt
	if [[ -f $metadataFile ]]; then
		systemMetadata=$(cat $metadataFile)
		fileExtensions=$(grep -E '^extensions' $metadataFile)
		extensions="${fileExtensions/"extensions: "/""}"
	else
		systemMetadata=""
		extensions=""
	fi

	#Roms loop
	for entry in $romsPath/$system/*
	do

		#Cleaning up names
		firstString=$entry
		secondString=""
		romName="${firstString/"$romsPath/$system/"/"$secondString"}"
		romNameNoExtension=${romName%.*}
		startcapture=true

		#.txt validation
		STR=$romName
		SUB='.txt'
		if grep -q "$SUB" <<< "$STR"; then
			continue;
		fi
		#.sav validation
		STR=$romName
		SUB='.sav'
		if grep -q "$SUB" <<< "$STR"; then
			continue;
		fi
		#.srm validation
		 STR=$romName
		 SUB='.srm'
		 if grep -q "$SUB" <<< "$STR"; then
			 continue;
		 fi

		#Directory Validation
		DIR=$romsPath/$system/$romName
		if [ -d "$DIR" ]; then
			continue;
		fi
		#Extension Validation
		#"" means metadata couldn't be parsed, no extensions to check
		if [[ $extensions == "" ]]; then
			startcapture=true
		else
			if grep -q "${romName##*.}" <<< "$extensions"]; then
				startcapture=true
			else
				continue;
			fi
		fi

		#Blanks cleaning up, TODO: DRY
		firstString=$romNameNoExtension
		secondString=""
		romNameNoExtensionNoDisc="${firstString/"Disc "/""}"
		firstString=$romNameNoExtensionNoDisc
		romNameNoExtensionNoRev="${firstString/"Rev "/""}"
		firstString=$romNameNoExtensionNoRev
		romNameNoExtensionTrimmed=$(echo $firstString | sed 's/ ([^()]*)//g' | sed 's/ [[A-z0-9!+]*]//g' | sed 's/([^()]*)//g' | sed 's/[[A-z0-9!+]*]//g')
		firstString=$romNameNoExtensionTrimmed
		romNameNoExtensionNoAnd="${firstString/"&"/"$secondString"}"
		firstString=$romNameNoExtensionNoAnd
		secondString="%20"
		romNameNoExtensionNoDash="${firstString/" - "/"$secondString"}"
		firstString=$romNameNoExtensionNoDash
		romNameNoExtensionNoDash="${firstString/"-"/"$secondString"}"
		firstString=$romNameNoExtensionNoDash
		romNameNoExtensionNoSpace="${firstString//" "/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace
		secondString=""
		romNameNoExtensionNoNkit="${firstString/".nkit"/"$secondString"}"
		firstString=$romNameNoExtensionNoNkit
		romNameNoExtensionNoSpace="${firstString/"!"/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace

		if [ $startcapture == true ]; then
			hasWheel=false
			hasSs=false
			hasBox=false
			hasMetadata=false

			FILE=$romsPath/$system/media/wheel/$romNameNoExtension.png
			if [ -f "$FILE" ]; then
				hasWheel=true
			fi

			FILE=$romsPath/$system/media/screenshot/$romNameNoExtension.png
			if [ -f "$FILE" ]; then
				hasSs=true
			fi

			FILE=$romsPath/$system/media/box2dfront/$romNameNoExtension.png
			if [ -f "$FILE" ]; then
				hasBox=true
			fi

			if [[ $systemMetadata == "" ]] || [[ $systemMetadata == *"game: $romNameNoExtensionTrimmed"* ]]; then
				hasMetadata=true
			fi

			#We only search games with no art or metadata
			if [ $hasWheel == false ] || [ $hasSs == false ] || [ $hasBox == false ] || ([ $hasMetadata == false ] && [ $saveMetadata == true ]); then
			#Second Scan: Screenscraper
				url="https://www.screenscraper.fr/api2/jeuInfos.php?devid=djrodtc&devpassword=diFay35WElL&softname=zzz&output=json&ssid=${userSS}&sspassword=${passSS}&crc=&systemeid=${ssID}&romtype=rom&romnom=${romNameNoExtensionNoSpace}.zip"

				#ID Game
				content=$(curl "$url")

				#Don't check art if screenscraper is closed
				if [[ $content == *"API closed"* ]]; then
					echo -e "The Screenscraper API is currently down, please try again later."
					echo -e  "Press the ${RED}A button${NONE} to finish"
					read pause
					am startservice -a com.termux.service_stop com.termux/.app.TermuxService &> /dev/null
				fi
				#Don't check art after a failed curl request
				if [[ $content == "" ]]; then
					echo -e "Request failed to send for $romNameNoExtensionTrimmed, ${YELLOW}skipping${NONE}"
					echo ""
					echo "Request failed for $romNameNoExtensionTrimmed" >> $HOME/shared/scrap.log
					continue;
				fi
				#Don't check art if screenscraper can't find a match
				if [[ $content == *"Erreur"* ]]; then
					echo -e "Couldn't find a match for $romNameNoExtensionTrimmed, ${YELLOW}skipping${NONE}"
					echo ""
					echo "Couldn't find a match for $romNameNoExtensionTrimmed" >> $HOME/shared/scrap.log
					continue;
				fi

				gameIDSS=$( jq -r  '.response.jeu.id' <<< "${content}" )

				urlMediaWheel="https://www.screenscraper.fr/api2/mediaJeu.php?devid=djrodtc&devpassword=diFay35WElL&softname=zzz&ssid=${userSS}&sspassword=${passSS}&crc=&md5=&sha1=&systemeid=${ssID}&jeuid=${gameIDSS}&media=wheel(wor)"
				urlMediaWheelHD="https://www.screenscraper.fr/api2/mediaJeu.php?devid=djrodtc&devpassword=diFay35WElL&softname=zzz&ssid=${userSS}&sspassword=${passSS}&crc=&md5=&sha1=&systemeid=${ssID}&jeuid=${gameIDSS}&media=wheel-hd(wor)"
				urlMediaSs="https://www.screenscraper.fr/api2/mediaJeu.php?devid=djrodtc&devpassword=diFay35WElL&softname=zzz&ssid=${userSS}&sspassword=${passSS}&crc=&md5=&sha1=&systemeid=${ssID}&jeuid=${gameIDSS}&media=ss(wor)"
				urlMediaBox="https://www.screenscraper.fr/api2/mediaJeu.php?devid=djrodtc&devpassword=diFay35WElL&softname=zzz&ssid=${userSS}&sspassword=${passSS}&crc=&md5=&sha1=&systemeid=${ssID}&jeuid=${gameIDSS}&media=box-2D(wor)"
				wheelSavePath="./storage/$romsPath/$system/media/wheel/$romNameNoExtension.png"
				ssSavePath="./storage/$romsPath/$system/media/screenshot/$romNameNoExtension.png"
				box2dfrontSavePath="./storage/$romsPath/$system/media/box2dfront/$romNameNoExtension.png"

				echo -e "Downloading Images for $romNameNoExtensionTrimmed - $gameIDSS"

				if [ $hasWheel == true ]; then
					echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
				else
					scrap_ss "$urlMediaWheel" "$wheelSavePath" "Wheel"
				fi

				if [ $hasSs == true ]; then
					echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
				else
					scrap_ss "$urlMediaSs" "$ssSavePath" "Screenshot"
				fi

				if [ $hasBox == true ]; then
					echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
				else
					scrap_ss "$urlMediaBox" "$box2dfrontSavePath" "2D Box"
				fi
				#Wheel HD just in case
				FILE=$romsPath/$system/media/wheel/$romNameNoExtension.png
				if [ -f "$FILE" ]; then
					hasWheel=true
				fi

				if [ $hasWheel == true ]; then
					echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
				else
					scrap_ss "$urlMediaWheelHD" "$wheelSavePath" "Wheel HD"
				fi

				if [ $saveMetadata == true ]; then
					if [[ $hasMetadata == true ]]; then
						echo -e "Metadata already exists for $romNameNoExtensionTrimmed, ${YELLOW}ignoring${NONE}"
						continue;
					fi

					genre_array=$( jq -r '[foreach .response.jeu.genres[].noms[] as $item ([[],[]]; if $item.langue == "en" then $item.text else "" end)]' <<< "${content}" )
					echo "" >> ./storage/$romsPath/$system/metadata.pegasus.txt
					echo "" >> ./storage/$romsPath/$system/metadata.pegasus.txt
					echo game: $romNameNoExtensionTrimmed >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo file: $romName >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo developer: $( jq -r  '.response.jeu.developpeur.text' <<< "${content}" ) >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo publisher: $( jq -r  '.response.jeu.editeur.text' <<< "${content}" ) >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo genre: $( jq '. - [""] | join(", ")' <<< "${genre_array}" ) | sed 's/[\"]//g' >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo description: $( jq -r  '.response.jeu.synopsis[0].text' <<< "${content}" ) >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo release: $( jq -r  '.response.jeu.dates[0].text' <<< "${content}" ) >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo players: $( jq -r  '.response.jeu.joueurs.text' <<< "${content}" ) >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo rating: $( jq -r  '.response.jeu.classifications[0].text' <<< "${content}" ) >> ./storage/${romsPath}/${system}/metadata.pegasus.txt
					echo assets.logo: ./media/wheel/$romNameNoExtension.png >> ./storage/$romsPath/$system/metadata.pegasus.txt
					echo assets.screenshot: ./media/screenshot/$romNameNoExtension.png >> ./storage/$romsPath/$system/metadata.pegasus.txt
					echo assets.boxfront: ./media/box2dfront/$romNameNoExtension.png >> ./storage/$romsPath/$system/metadata.pegasus.txt

					echo -e "Metadata saved to ${system}/metadata.pegasus.txt"
				fi

			else
				echo -e "Game already scraped" &> /dev/null
			fi
		fi
	done
done