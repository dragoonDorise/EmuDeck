#!/bin/bash
#Colors
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

clear
echo -e "${BOLD}EmuDeck has finished!${NONE}"
echo ""
echo -e "If you want to update or change your configuration just open Termux again"
echo ""
#Copy roms

echo -e "${BOLD}- How to add games${NONE}"

if [ $romPath == 'SDCARD' ]; then	
		echo -e  "You need to manually move your roms folder before starting"
		echo -e  "Open any File manager app and move the ${GREEN}/Emulation${NONE} folder to your SD Card root"	
		echo -e  "Now, connect your device to a computer and copy your roms to the proper folders ( each system has its own subfolder )"	
else
		echo -e  "You can now start copying your roms!"	
		echo -e  "Connect your device to a computer and copy your roms to the proper folders ( each system has its own subfolder ) inside ${GREEN}/Emulation/roms${NONE}"
fi

echo ""
echo -e "${BOLD}- How to launch your games${NONE}"
#Easy
if [ $expert == false ]; then
	echo -e "We've installed for you Daijisho so you can use it as a frontend for all your systems"
	echo -e "You need to Open Daijisho From your apps and manually configure it with your custom paths"
	echo ""
	echo -e "First, open Daijisho and select the Systems you want to use by clicking on the Download Platforms button"
	echo -e "Now click on Paths, Add more"
	echo -e "Select the system folder ( ie: Super Nintendo )"
	if [ $romPath == 'SDCARD' ]; then
		if [ $android -gt 10 ]; then
			echo -e "SD Card: ${GREEN}Emulation/roms/snes${NONE}"
		else
			echo -e "SD Card: ${GREEN}/Android/data/com.termux/files/Emulation/roms/snes${NONE}"
		fi
	else
		echo -e "${GREEN}/Emulation/roms${NONE}"
	fi
	echo -e "Now press on Sync and Daijisho Will Start downloading artbox for your games!"
	
fi

echo ""
echo -e "${BOLD}- RetroArch Cores${NONE}"
echo -e "You need to manually install your cores before playing games, open RetroArch and go to"
echo -e "Main Menu -> Online Update -> Core Downloader"
echo -e "and download at least these Cores:"
echo -e "Arcade (MAME 2003 Plus), Gambatte, Mesen, Snes9x - Current, Genesis Plus GX, PicoDrive"
echo -e "If you want to emulate more systems you can download other cores too" 


if [ $android -lt 11 ] && [ $romPath != 'INTERNAL' ]; then
	echo ""
	echo -e "${RED}IMPORTANT${NONE}"
	echo -e "Be aware that if you delete the Termux app Android will ${RED}DELETE${NONE} the Termux folder on your SD Card including your roms"	
fi

if [ $doInstallPegasus == true ]; then
		echo ""
		echo -e  "${RED}Pegasus Warning${NONE}"	
	if [ $android -gt 10 ]; then
		if [ $romPath == 'SDCARD' ]; then
			echo -e  "The Pegasus Artwork Scrapper only works on if you keep your roms on your Internal Storage"			
			echo -e  "So you'll also need to connect your device on your computer to get your Artwork"			
			echo -e  "We recommend using www.skraper.net"
			echo -e  "Remember to manually copy the Emulation folder from your Internal Storage to your SD Card"
			echo -e  "Press the ${RED}A Button${NONE} to open a written guide of how to use Skraper"
			read pause
			termux-open "https://retrogamecorps.com/2021/04/02/quick-guide-skraper-for-retro-handheld-devices/"
		fi
	else
		echo -e "Once you've copied your roms to their proper folders, you need to run our Pegasus Artwork Scrapper"
		echo -e "Open Termux again when you've copied them and select the Pegasus Artwork Scrapper option"
	fi	
fi
echo -e ""
echo -e  "Scroll Up to read all the final instructions and then press the ${RED}A Button${NONE} to Exit"
read pause