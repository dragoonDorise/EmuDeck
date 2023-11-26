#!/bin/bash

romParser_RA_download(){
	local romName=$1
	local system=$2
	local type=$3

	case "$type" in
		"screenshot")
			RA_folder="Named_Snaps"

			;;
		*)
			RA_folder="Named_Boxarts"
			;;
	esac

	FILE=$romsPath/$system/media/$type/$romName.png
	if [ -f "$FILE" ]; then
		echo -e "Image already exists, ${YELLOW}ignoring${NONE}"
	else
		status=$(wget --spider "http://thumbnails.libretro.com/$remoteSystem/$RA_folder/$romName.png" 2>&1)
		if [[ $status == *"image/png"* ]] || [[ $status == *"image/jpeg"* ]] || [[ $status == *"image/jpg"* ]]; then
			wget  -q --show-progress "http://thumbnails.libretro.com/$remoteSystem/$RA_folder/$romName.png" -P "$romsPath/$system/media/$type/"
		else
			echo -e "Image not found: $romName $type..."
		fi
	fi
}

romParser_RA_getAlias(){
	case $1 in
		atari2600)
			remoteSystem="Atari - 2600"
			;;
		atari5200)
			remoteSystem="Atari - 5200"
		;;
		atari7800)
			remoteSystem="Atari - 7800"
		;;
		lynx)
			remoteSystem="Atari - Lynx"
			;;
		doom)
			remoteSystem="DOOM"
			;;
		dos)
			remoteSystem="DOS"
			;;
		fbneo)
			remoteSystem="FBNeo - Arcade Games"
			;;
		pcengine)
			remoteSystem="NEC - PC Engine - TurboGrafx 16"
			;;
		pcenginecd)
			remoteSystem="NEC - PC Engine CD - TurboGrafx-CD"
			;;
		gb)
			remoteSystem="Nintendo - Game Boy"
			;;
		gba)
			remoteSystem="Nintendo - Game Boy Advance"
			;;
		gbc)
			remoteSystem="Nintendo - Game Boy Color"
			;;
		gc)
			remoteSystem="Nintendo - GameCube"
			;;
		3ds)
			remoteSystem="Nintendo - Nintendo 3DS"
			;;
		n64)
			remoteSystem="Nintendo - Nintendo 64"
			;;
		nds)
			remoteSystem="Nintendo - Nintendo DS"
			;;
		nes)
			remoteSystem="Nintendo - Nintendo Entertainment System"
			;;
		pokemini)
			remoteSystem="Nintendo - Pokemon Mini"
			;;
		snes)
			remoteSystem="Nintendo - Super Nintendo Entertainment System"
			;;
		wii)
			remoteSystem="Nintendo - Wii"
			;;
		neogeo)
			remoteSystem="SNK - Neo Geo"
			;;
		neogeocd)
			remoteSystem="SNK - Neo Geo CD"
			;;
		ngp)
			remoteSystem="SNK - Neo Geo Pocket"
			;;
		ngpc)
			remoteSystem="SNK - Neo Geo Pocket Color"
			;;
		scummvm)
			remoteSystem="ScummVM"
			;;
		sega32x)
			remoteSystem="Sega - 32X"
			;;
		dreamcast)
			remoteSystem="Sega - Dreamcast"
			;;
		gamegear)
			remoteSystem="Sega - Game Gear"
			;;
		mastersystem)
			remoteSystem="Sega - Master System - Mark III"
			;;
		genesis)
			remoteSystem="Sega - Mega Drive - Genesis"
			;;
		genesiswide)
			remoteSystem="Sega - Mega Drive - Genesis"
			;;

		segacd)
			remoteSystem="Sega - Mega-CD - Sega CD"
			;;
		saturn)
			remoteSystem="Sega - Saturn"
			;;
		psx)
			remoteSystem="Sony - PlayStation"
			;;
		ps2)
			remoteSystem="Sony - PlayStation 2"
			;;
		psp)
			remoteSystem="Sony - PlayStation Portable"
			;;
		3do)
			remoteSystem="The 3DO Company - 3DO"
			;;
		amstradcpc)
			remoteSystem="Amstrad - CPC"
			;;
		atarist)
			remoteSystem="Atari - ST"
			;;
		colecovision)
			remoteSystem="Coleco - ColecoVision"
			;;
		intellivision)
			remoteSystem="Mattel - Intellivision"
			;;
		lutro)
			remoteSystem="Lutro"
			;;
		msx)
			remoteSystem="Microsoft - MSX"
			;;
		tic80)
			remoteSystem="TIC-80"
			;;
		vectrex)
			remoteSystem="GCE - Vectrex"
			;;
		zxspectrum)
			remoteSystem="Sinclair - ZX Spectrum"
			;;
	  *)
		#echo -n "unknown"
		;;
	esac
}

romParser_RA_start(){
	echo -e "${BOLD}Starting RetroArch Thumbnails Scraper...${NONE}"
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

				#We get the folder RA uses
				(romParser_RA_getAlias $system
				romParser_RA_download "$romName" $system "screenshot"
				romParser_RA_download "$romName" $system "box2dfront")  |
				zenity --progress \
				  --title="EmuDeck RetroArch Parser" \
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
