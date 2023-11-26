#!/bin/sh
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
echo "" > "$HOME/emudeck/logs/parser.log"

romsPath=$romsPath
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

get_sc_id(){
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



scrap_ss () {
	urlMedia=$1
	urlSave=$2
	media=$3
	echo -e "${BOLD}Scraping: $media.${NONE}"
	StatusString=$(wget --spider "$urlMedia" 2>&1)
	echo -ne "${BOLD}Searching World Region..."
	if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
		wget -q --show-progress "$urlMedia" -O "$urlSave" &> /dev/null
		echo -e "${GREEN}Found it!${NONE}"
	else
		echo -ne "${BOLD}Searching US Region..."
		firstString="$urlMedia"
		secondString="(us)"
		urlMedia="${firstString/(wor)/"$secondString"}"
		StatusString=$(wget --spider "$urlMedia" 2>&1)
		if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
			wget -q --show-progress "$urlMedia" -O "$urlSave" &> /dev/null
			echo -e "${GREEN}Found it!${NONE}"
		else
			echo -ne "${BOLD}Searching EU Region..."
			firstString="$urlMedia"
			secondString="(eu)"
			urlMedia="${firstString/(us)/"$secondString"}"
			StatusString=$(wget --spider "$urlMedia" 2>&1)
			if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
				wget -q --show-progress "$urlMedia" -O "$urlSave" &> /dev/null
				echo -e "${GREEN}Found it!${NONE}"

			else
				echo -ne "${BOLD}Searching USA Region..."
				firstString="$urlMedia"
				secondString="(usa)"
				urlMedia="${firstString/(eu)/"$secondString"}"
				StatusString=$(wget --spider "$urlMedia" 2>&1)
				if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
					wget -q --show-progress "$urlMedia" -O "$urlSave" &> /dev/null
					echo -e "${GREEN}Found it!${NONE}"
				else
					echo -ne "${BOLD}Searching Custom Region..."
					firstString="$urlMedia"
					secondString="(cus)"
					urlMedia="${firstString/(usa)/"$secondString"}"
					StatusString=$(wget --spider "$urlMedia" 2>&1)
					if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
						wget -q --show-progress "$urlMedia" -O "$urlSave" &> /dev/null
						echo -e "${GREEN}Found it!${NONE}"
					else
						echo -ne "${BOLD}Searching No Region..."
						firstString="$urlMedia"
						secondString=""
						urlMedia="${firstString/(cus)/"$secondString"}"
						StatusString=$(wget --spider "$urlMedia" 2>&1)
						if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
							wget -q --show-progress "$urlMedia" -O "$urlSave" &> /dev/null
							echo -e "${GREEN}Found it!${NONE}"

						else
							echo $urlMedia >> $HOME/shared/scrap.log &> /dev/null
							echo -e "${RED}NO IMG FOUND${NONE}"
						fi
					fi
				fi
			fi
		fi
	fi
}


clear


selected_device_descriptions="ALL"

selected_device_descriptions_all="atari2600 atari5200 atari7800 lynx doom dos fbneo pcengine pcenginecd gb gba gbc gc 3ds n64 nds nes pokemini snes sneswide wii neogeo neogeocd ngp ngpc scummvm sega32x dreamcast gamegear mastersystem genesis genesiswide segacd saturn psx ps2 psp 3do amstradcpc atarist colecovision intellivision lutro msx tic80 vectrex zxspectrum"
mapfile -t selected_device_names <<< $selected_device_descriptions_all
clear

# scrapers_names=$(whiptail --title "Choose your Scrape Engine - We recomend to choose all of them" \
# 	--checklist "Move using your DPAD and select your options with the Y button. Press the A button to select." 10 80 4 \
# 	"RETROARCH" "Retroarch Thumbs - Fast but only works on No Intro Romsets" ON \
# 	"LAUNCHBOX" "Launchbox GamesDB - Fast - Still on beta" ON \
# 	"SCREENSCRAPER" "ScreenScraper - Really really slow but more reliable" ON \
# 	3>&1 1<&2 2>&3)
#
# clear
# mapfile -t scrapers <<< $scrapers_names

scrapers_names='RETROARCH';
mapfile -t scrapers <<< $scrapers_names

for scraper in ${scrapers[@]};
 do

	if [[ $scraper == *"RETROARCH"* ]]; then
		. "./scrapers/retroarch.sh"
		#. "$HOME/.config/EmuDeck/backend/tools/scrapers/retroarch.sh"
	fi

	if [[ $scraper == *"LAUNCHBOX"* ]]; then
	echo "LAUNCHBOX!"
	read pause
		. "./scrapers/launchbox.sh"
		#. "$HOME/.config/EmuDeck/backend/tools/scrapers/launchbox.sh"
	fi

	if [[ $scraper == *"SCREENSCRAPER"* ]]; then
	echo "SCREENSCRAPER!"
	read pause
		. "./scrapers/screenscraper.sh"
		#. "$HOME/.config/EmuDeck/backend/tools/scrapers/screenscraper.sh"
	fi
done