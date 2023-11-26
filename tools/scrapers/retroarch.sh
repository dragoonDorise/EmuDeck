#!/bin/bash

get_ra_alias(){
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

clear
#echo -e "Using Retroarch Thumbnails..."
for device_name in $romsPath/*;
 do

	 message=$device_name
	 systemPath=$(echo "$message" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')
	 #ls $systemPath
	 #echo -e "Creating $systemPath/media..."
	 mkdir $systemPath/media &> /dev/null
	 mkdir $systemPath/media/screenshot &> /dev/null
	 mkdir $systemPath/media/box2dfront &> /dev/null
	 mkdir $systemPath/media/wheel &> /dev/null

	 #Retroarch system folder name
	 get_ra_alias $systemPath

	 if [ "$remoteSystem" = 'unknown' ]; then
	  #echo -e " - Skipping"
	 	exit
	 fi

	 #echo ""
	 #echo -e "Scraping $systemPath..."
	 #echo ""
	 #Roms loop
	 for entry in "$romsPath/$systemPath/"*
	 do
		 #Cleaning up names
		firstString=$entry
		secondString=""
		romName="${firstString/"$systemPath/"/"$secondString"}"
		romNameNoExtension=${romName%.*}

		startcapture=true
		#echo $romName
		#.txt validation
		 STR=$romName
		 SUB='.txt'
		 if grep -q "$SUB" <<< "$STR"; then
			 startcapture=false
		 fi
		#.sav validation
		 STR=$romName
		 SUB='.sav'
		 if grep -q "$SUB" <<< "$STR"; then
			 startcapture=false
		 fi
		#.srm validation
		 STR=$romName
		 SUB='.srm'
		 if grep -q "$SUB" <<< "$STR"; then
			 startcapture=false
		 fi

		#Directory Validation
		DIR=$systemPath/$romName
		if [ -d "$DIR" ]; then
			startcapture=false
		fi

		#Blanks cleaning up, TODO: DRY
		firstString=$romNameNoExtension
		secondString="%20"
		romNameNoExtensionNoSpace="${firstString/" "/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace
		secondString="%20"
		romNameNoExtensionNoSpace="${firstString/" "/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace
		secondString="%20"
		romNameNoExtensionNoSpace="${firstString/" "/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace
		secondString="%20"
		romNameNoExtensionNoSpace="${firstString/" "/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace
		secondString="%20"
		romNameNoExtensionNoSpace="${firstString/" "/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace
		secondString="%20"
		romNameNoExtensionNoSpace="${firstString/" "/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace
		secondString="%20"
		romNameNoExtensionNoSpace="${firstString/" "/"$secondString"}"
		firstString=$romNameNoExtensionNoSpace
		secondString="%20"
		romNameNoExtensionNoSpace="${firstString/" "/"$secondString"}"

		romNameNoExtension=$(echo "$romNameNoExtension" | sed 's/.*\/\([^\/]*\)\/\?$/\1/')

		if [ $systemPath = "mame" ]; then
			startcapture=false
		fi

		if [ $systemPath = "cloud" ]; then
			startcapture=false
		fi

		if [ -d $systemPath ]; then
			startcapture=false
		fi

		if [ $startcapture == true ]; then

			#First Scan: Retroarch
			FILE=$systemPath/media/screenshot/$romNameNoExtension.png
			if [ -f "$FILE" ]; then
				echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
			else
				if [ ! "$romNameNoExtension" = "*" ]; then
					echo  "PIC"
					echo "http://thumbnails.libretro.com/$remoteSystem/Named_Snaps/$romNameNoExtension.png";

					StatusString=$(wget --spider "http://thumbnails.libretro.com/$remoteSystem/Named_Snaps/$romNameNoExtension.png" 2>&1)
					if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
						wget  -q --show-progress "http://thumbnails.libretro.com/$remoteSystem/Named_Snaps/$romNameNoExtension.png" -P $romsPath/$systemPath/media/screenshot/
					else
						echo -e "Image not found: $romNameNoExtension screenshot..."
					fi
				fi

			fi

			FILE=$systemPath/media/box2dfront/$romNameNoExtension.png
			if [ -f "$FILE" ]; then
				echo -e "Image already exists, ${YELLOW}ignoring${NONE}" &> /dev/null
			else
				if [ ! "$romNameNoExtension" = "*" ]; then
					StatusString=$(wget --spider "http://thumbnails.libretro.com/$remoteSystem/Named_Boxarts/$romNameNoExtension.png" 2>&1)
					if [[ $StatusString == *"image/png"* ]] || [[ $StatusString == *"image/jpeg"* ]] || [[ $StatusString == *"image/jpg"* ]]; then
						wget  -q --show-progress "http://thumbnails.libretro.com/$remoteSystem/Named_Boxarts/$romNameNoExtension.png" -P $romsPath/$systemPath/media/box2dfront/
						#echo -e ""
					else
						echo -e "Image not found: $romNameNoExtension box2dfront..."
					fi
				fi
			fi
		fi

	 done
 done

#echo -e "${GREEN}completed${NONE}"


