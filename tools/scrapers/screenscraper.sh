#!/bin/bash
romParser_SS_download(){
	local romName=$1
	local system=$2
	local type=$3
	local userSS=$(cat "$HOME/emudeck/.userSS")
	local passSS=$(cat "$HOME/emudeck/.passSS")
	#local ssID Set but calling romParser_SS_getAlias before
	case "$type" in
		"wheel")
			media="wheel"
			;;
		"screenshot")
			media="ss"
			;;
		*)
			media="box-2D"
			;;
	esac

	FILE=$romsPath/$system/media/$type/$romName.png
	if [ -f "$FILE" ]; then
		echo -e "Image already exists, ${YELLOW}ignoring${NONE}"
	else
		#We get the gameIDSS
		urlIDSS="https://www.screenscraper.fr/api2/jeuInfos.php?devid=djrodtc&devpassword=diFay35WElL&softname=zzz&output=json&ssid=${userSS}&sspassword=${passSS}&crc=&systemeid=${ssID}&romtype=rom&romnom=${romName}.zip"

		#Cleaning URL
		urlIDSS=$(echo "$urlIDSS" | sed 's/ /%20/g')

		#ID Game
		content=$(curl $urlIDSS)
		#Don't check art if screenscraper is closed
		if [[ $content == *"API closed"* ]]; then
			echo -e "The Screenscraper API is currently down, please try again later."
			exit
		fi
		#Don't check art after a failed curl request
		if [[ $content == "" ]]; then
			echo -e "Request failed to send for $romName, ${YELLOW}skipping${NONE}"
			echo ""
			echo "Request failed for $romName"
			exit
		fi
		#Don't check art if screenscraper can't find a match
		if [[ $content == *"Erreur"* ]]; then
			echo -e "Couldn't find a match for $romName, ${YELLOW}skipping${NONE}"
			echo ""
			echo "Couldn't find a match for $romName"
			exit
		fi

		gameIDSS=$( jq -r  '.response.jeu.id' <<< "${content}" )

		#Downloading art!
		local url="https://www.screenscraper.fr/api2/mediaJeu.php?devid=djrodtc&devpassword=diFay35WElL&softname=EmuDeck&ssid=${userSS}&sspassword=${passSS}&crc=&md5=&sha1=&systemeid=${ssID}&jeuid=${gameIDSS}&media=${media}(wor)"


		urlSave="$romsPath/$system/media/$media/$romName.png"
		echo $urlSave

		echo -e "${BOLD}Scraping: $media${NONE}"
		StatusString=$(wget --spider "$url" 2>&1)
		echo -ne "${BOLD}Searching World Region..."
		if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
			wget -q --show-progress "$url" -O "$urlSave" &> /dev/null
			echo -e "${GREEN}Found it!${NONE}"
		else
			echo -ne "${BOLD}Searching US Region..."
			firstString="$url"
			secondString="(us)"
			url="${firstString/(wor)/"$secondString"}"
			StatusString=$(wget --spider "$url" 2>&1)
			if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
				wget -q --show-progress "$url" -O "$urlSave" &> /dev/null
				echo -e "${GREEN}Found it!${NONE}"
			else
				echo -ne "${BOLD}Searching EU Region..."
				firstString="$url"
				secondString="(eu)"
				url="${firstString/(us)/"$secondString"}"
				StatusString=$(wget --spider "$url" 2>&1)
				if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
					wget -q --show-progress "$url" -O "$urlSave" &> /dev/null
					echo -e "${GREEN}Found it!${NONE}"

				else
					echo -ne "${BOLD}Searching USA Region..."
					firstString="$url"
					secondString="(usa)"
					url="${firstString/(eu)/"$secondString"}"
					StatusString=$(wget --spider "$url" 2>&1)
					if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
						wget -q --show-progress "$url" -O "$urlSave" &> /dev/null
						echo -e "${GREEN}Found it!${NONE}"
					else
						echo -ne "${BOLD}Searching Custom Region..."
						firstString="$url"
						secondString="(cus)"
						url="${firstString/(usa)/"$secondString"}"
						StatusString=$(wget --spider "$url" 2>&1)
						if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
							wget -q --show-progress "$url" -O "$urlSave" &> /dev/null
							echo -e "${GREEN}Found it!${NONE}"
						else
							echo -ne "${BOLD}Searching No Region..."
							firstString="$url"
							secondString=""
							url="${firstString/(cus)/"$secondString"}"
							StatusString=$(wget --spider "$url" 2>&1)
							if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
								wget -q --show-progress "$url" -O "$urlSave" &> /dev/null
								echo -e "${GREEN}Found it!${NONE}"

							else
								echo -e "${RED}NO IMG FOUND${NONE}"
							fi
						fi
					fi
				fi
			fi
		fi
	fi
}

romParser_SS_getAlias(){
	#SS ID systems
	case $1 in
		genesis)
		ssID="1";;
		genesiswide)
		ssID="1";;
		mastersystem)
		ssID="2";;
		nes)
		ssID="3";;
		snes)
		ssID="4";;
		gb)
		ssID="9";;
		gbc)
		ssID="10";;
		virtualboy)
		ssID="11";;
		gba)
		ssID="12";;
		gc)
		ssID="13";;
		n64)
		ssID="14";;
		nds)
		ssID="15";;
		wii)
		ssID="16";;
		3ds)
		ssID="17";;
		sega32x)
		ssID="19";;
		segacd)
		ssID="20";;
		gamegear)
		ssID="21";;
		saturn)
		ssID="22";;
		dreamcast)
		ssID="23";;
		ngp)
		ssID="25";;
		atari2600)
		ssID="26";;
		jaguar)
		ssID="27";;
		lynx)
		ssID="28";;
		3do)
		ssID="29";;
		pcengine)
		ssID="31";;
		bbcmicro)
		ssID="37";;
		atari5200)
		ssID="40";;
		atari7800)
		ssID="41";;
		atarist)
		ssID="42";;
		atari800)
		ssID="43";;
		wswan)
		ssID="45";;
		wswanc)
		ssID="46";;
		colecovision)
		ssID="48";;
		pcengine)
		ssID="50";;
		gw)
		ssID="52";;
		psx)
		ssID="57";;
		ps2)
		ssID="58";;
		psp)
		ssID="61";;
		amiga600)
		ssID="64";;
		amstradcpc)
		ssID="65";;
		c64)
		ssID="66";;
		scv)
		ssID="67";;
		neogeocd)
		ssID="70";;
		pcfx)
		ssID="72";;
		vic20)
		ssID="73";;
		zxspectrum)
		ssID="76";;
		zx81)
		ssID="77";;
		x68000)
		ssID="79";;
		channelf)
		ssID="80";;
		ngpc)
		ssID="82";;
		apple2)
		ssID="86";;
		gx4000)
		ssID="87";;
		dragon)
		ssID="91";;
		bk)
		ssID="93";;
		vectrex)
		ssID="102";;
		supergrafx)
		ssID="105";;
		fds)
		ssID="106";;
		satellaview)
		ssID="107";;
		sufami)
		ssID="108";;
		sg1000)
		ssID="109";;
		amiga1200)
		ssID="111";;
		msx)
		ssID="113";;
		pcenginecd)
		ssID="114";;
		intellivision)
		ssID="115";;
		msx2)
		ssID="116";;
		msxturbor)
		ssID="118";;
		64dd)
		ssID="122";;
		scummvm)
		ssID="123";;
		gb)
		ssID="127";;
		gb)
		ssID="128";;
		amigacdtv)
		ssID="129";;
		amigacd32)
		ssID="130";;
		oricatmos)
		ssID="131";;
		amiga)
		ssID="134";;
		dos)
		ssID="135";;
		prboom)
		ssID="135";;
		amigacd32)
		ssID="139";;
		thomson)
		ssID="141";;
		neogeo)
		ssID="142";;
		psp)
		ssID="172";;
		snes)
		ssID="202";;
		sneswide)
		ssID="202";;
		megadrive)
		ssID="203";;
		ti994a)
		ssID="205";;
		lutro)
		ssID="206";;
		supervision)
		ssID="207";;
		pc98)
		ssID="208";;
		pokemini)
		ssID="211";;
		samcoupe)
		ssID="213";;
		openbor)
		ssID="214";;
		uzebox)
		ssID="216";;
		apple2gs)
		ssID="217";;
		spectravideo)
		ssID="218";;
		palm)
		ssID="219";;
		x1)
		ssID="220";;
		pc88)
		ssID="221";;
		tic80)
		ssID="222";;
		solarus)
		ssID="223";;
		mame)
		ssID="230";;
		easyrpg)
		ssID="231";;
		pico8)
		ssID="234";;
		pcv2)
		ssID="237";;
		pet)
		ssID="240";;
		lowresnx)
		ssID="244";;

	  *)
		echo -n "unknown"
		;;
	esac
}

romParser_SS_start(){

	echo -e "${BOLD}Starting ScreenScraper Thumbnails Scraper...${NONE}"

	for systemPath in $romsPath/*;
 	do
	 	system=$(echo "$systemPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')

		if [ ! -d "$systemPath/media/" ]; then
			echo -e "Creating $systemPath/media..."
			mkdir $systemPath/media &> /dev/null
			mkdir $systemPath/media/screenshot &> /dev/null
			mkdir $systemPath/media/box2dfront &> /dev/null
			mkdir $systemPath/media/wheel &> /dev/null
		fi

		romNumber=$(find "$systemPath" -maxdepth 1 -type f | wc -l)

		#Getting roms
		i=0
		for romPath in $systemPath/*;
		do
			#Validating
			if [ -f "$romPath" ] && [ "$(basename "$romPath")" != ".*" ] && [[ "$romPath" != *".txt" ]] && [[ "$(basename "$romPath")" != *".exe" ]] && [[ "$(basename "$romPath")" != *".conf" ]] && [[ "$(basename "$romPath")" != *".xml" ]]; then

				#Cleaning rom directory
				romfile=$(echo "$romPath" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')
				romName=$(basename "$romfile" .zip)

				if [ $i = 96 ]; then
					i=95
				fi

				(
					#We get the ssID for later
					romParser_SS_getAlias $system
					romParser_SS_download "$romName" $system "screenshot"
					romParser_SS_download "$romName" $system "box2dfront"
					romParser_SS_download "$romName" $system "wheel"
				) |
				zenity --progress \
				  --title="EmuDeck ScreenScraper Parser" \
				  --text="Downloading artwork for $system..." \
				  --auto-close \
				  --pulsate \
				  --percentage=$i

				((i++))
			fi
		done

	done
	echo -e "${GREEN}RetroArch Parser completed!${NONE}"
}