#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\x1b[5m'

if [ ! -f "$HOME/.config/EmuDeck/.userSS" ]; then
	user=$(zenity --entry --title="ScreenScrapper" --text="User:")
	password=$(zenity --password --title="ScreenScrapper" --text="Password:")
	encryption_key=$(openssl rand -base64 32)
	encrypted_password=$(echo "$password" | openssl enc -aes-256-cbc -pbkdf2 -base64 -pass "pass:$encryption_key")
	echo "$encryption_key" > "$HOME/.config/EmuDeck/logs/.key"
	echo "$encrypted_password" > "$HOME/.config/EmuDeck/.passSS"
	echo "$user" > "$HOME/.config/EmuDeck/.userSS"
fi

romParser_SS_get_url(){
	local romName=$1
	local system=$2
	local type=$3
	local userSS=$(cat "$HOME/.config/EmuDeck/.userSS")
	local encryption_key=$(cat "$HOME/.config/EmuDeck/logs/.key")
	local encrypted_password=$(cat "$HOME/.config/EmuDeck/.passSS")
	local decrypted_password=$(echo "$encrypted_password" | openssl enc -d -aes-256-cbc -pbkdf2 -base64 -pass "pass:$encryption_key")
	local passSS=$decrypted_password

	rom_clean=$(echo "$romName" | sed 's/([^)]*)//g; s/\[[^]]*\]//g')
	rom_clean=$(echo "$rom_clean" | tr ' ' '_')
	rom_clean="${rom_clean%.*}"

	FILE=$romsPath/$system/media/$type/$romName.png
	if [ ! -f "$FILE" ]; then

		urlIDSS="https://www.screenscraper.fr/api2/jeuInfos.php?devid=djrodtc&devpassword=diFay35WElL&softname=zzz&output=json&ssid=${userSS}&sspassword=${passSS}&crc=&systemeid=${ssID}&romtype=rom&romnom=${rom_clean}"

		#echo $urlIDSS

		#Cleaning URL
		urlIDSS=$(echo "$urlIDSS" | sed 's/ /%20/g')

		#ID Game
		content=$(curl -s $urlIDSS)


		if [ $type = 'screenshots' ]; then
			echo "$content" | jq -r '.response.jeu.medias[] | select(.type == "ss") | .url' | head -n 1
		elif [ $type = 'wheel' ]; then
			echo "$content" | jq -r '.response.jeu.medias[] | select(.type == "wheel") | .url' | head -n 1
		elif [ $type = 'box2dfront' ]; then
			echo "$content" | jq -r '.response.jeu.medias[] | select(.type == "box-2D") | .url' | head -n 1
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
		atarijaguar)
		ssID="27";;
		atarijaguarcd)
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
		wonderswan)
		ssID="45";;
		wonderswancolor)
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

romParser_SS_download(){
	local games=$1
	local platform=$2
	local type=$3
	for game in $games; do
		#We bring back the spaces
		game=${game//_/ }
		 file_to_check="$romsPath/$platform/media/$type/${game}.png"

		 #echo $file_to_check

		 if ! ls "$file_to_check" 1> /dev/null 2>&1; then
		 #if ! ls $file_to_check 1> /dev/null 2>&1 && [ -z "${processed_games[$game]}" ]; then

			#romParser_SS_get_url "$game" $platform $type

			game_screenshot_url=$(romParser_SS_get_url "$game" $platform $type)


			if [[ "$game_screenshot_url" == *"screenscraper"* ]]; then

				echo -e ${GREEN}"$game added to batch"${NONE}

				download_array+=("$game_screenshot_url")
				download_dest_paths+=("$file_to_check")
				processed_games[$game]=1
				if [ ${#download_array[@]} -ge 10 ]; then
					echo ""
					echo "Start batch $platform $type"
					for i in "${!download_array[@]}"; do
						{
							curl -s -o "${download_dest_paths[$i]}" "${download_array[$i]}" > /dev/null 2>&1
						} &
					done
					wait
					# Clear the arrays for the next batch
					download_array=()
					download_dest_paths=()
					echo "Completed batch"
					echo ""
				fi
			else
				echo -e ${RED}"$game not found"${NONE}
			fi

		else
			echo -e ${CYAN}"$game already scraped"${NONE}
		fi
	done

}

romParser_SS_start(){
	#generateGameLists
	echo -e "${BOLD}Starting ScreenScraper Thumbnails Scraper...${NONE}"
	python $HOME/.config/EmuDeck/backend/tools/generate_game_lists.py "$romsPath"
	json=$(cat "$HOME/emudeck/cache/roms_games.json")
	platforms=$(echo "$json" | jq -r '.[].id')

	declare -A processed_games

	for platform in $platforms; do
		echo -e ${YELLOW}"Processing platform: $platform"${NONE}
		games=$(echo "$json" | jq -r --arg platform "$platform" '.[] | select(.id == $platform) | .games[]?.file')

		declare -a download_array
		declare -a download_dest_paths
		romParser_SS_getAlias $platform

		#screenshots

		romParser_SS_download "$games" "$platform" "screenshots"
		romParser_SS_download "$games" "$platform" "box2dfront"
		romParser_SS_download "$games" "$platform" "wheel"


		#Wheel


	done

	#Missing files
	for i in "${!download_array[@]}"; do
		{
			echo ${download_array[$i]}
			curl -s -o "${download_dest_paths[$i]}" "${download_array[$i]}" > /dev/null 2>&1
		} &
	done



	echo -e "${GREEN}ScreenScrapper Parser completed!${NONE}"
}
clear
#
romParser_SS_start
