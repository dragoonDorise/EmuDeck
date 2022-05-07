#!/bin/bash
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

doUninstall=false
doUninstallRA=false
doUninstallDolphin=false
doUninstallPCSX2=false
doUninstallRPCS3=false
doUninstallYuzu=false
doUninstallCitra=false
doUninstallDuck=false
doUninstallCemu=false
doUninstallXemu=false
doUninstallXenua=false
doUninstallPrimeHacks=false
doUninstallPPSSPP=false
doUninstallSRM=false
doUninstallESDE=false


#Wellcome
text="`printf "<b>Hi!</b>\nDo you really want to uninstall Emudek?\n\nIf you are having issues please go to our Discord, Reddit so we can help you. You can see the links here: https://www.emudeck.com/#download"`"
zenity --question \
		 --title="EmuDeck" \
		 --width=250 \
		 --ok-label="Nope, I want to uninstall EmuDeck" \
		 --cancel-label="Ok, I'll try one more time! Don't uninstall it yet" \
		 --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	doUninstall=true
else
	exit
fi


if [ "$doUninstall" == true ]; then 
	
	#Emulator selector
	text="`printf " <b>This will delete Emudeck , the emulators and all of its configuration files</b>\n\n You can keep the Emulators installed, tell me which ones you want to keep.\n\nIf you select none of them, everything will be deleted, including your saved games<b>We won't delete your roms</b>"`"
	emusToUninstall=$(zenity --list \
				--title="EmuDeck" \
				--height=500 \
				--width=250 \
				--ok-label="OK" \
				--cancel-label="Exit" \
				--text="${text}" \
				--checklist \
				--column="" \
				--column="Emulator" \
				1 "RetroArch"\
				2 "PrimeHack" \
				3 "PCSX2" \
				4 "RPCS3" \
				5 "Citra" \
				6 "Dolphin" \
				7 "Duckstation" \
				8 "PPSSPP" \
				9 "Yuzu" \
				10 "Xemu" \
				11 "Cemu" \
				12 "SteamRomManager" \
				13 "EmulationStationDE")
	clear
	ans=$?	
	if [ $ans -eq 0 ]; then
		
		if [[ "$emusToUninstall" == *"RetroArch"* ]]; then
			doUninstallRA=true
		fi
		if [[ "$emusToUninstall" == *"PrimeHack"* ]]; then
			doUninstallPrimeHacks=true
		fi
		if [[ "$emusToUninstall" == *"PCSX2"* ]]; then
			doUninstallPCSX2=true
		fi
		if [[ "$emusToUninstall" == *"RPCS3"* ]]; then
			doUninstallRPCS3=true
		fi
		if [[ "$emusToUninstall" == *"Citra"* ]]; then
			doUninstallCitra=true
		fi
		if [[ "$emusToUninstall" == *"Dolphin"* ]]; then
			doUninstallDolphin=true
		fi
		if [[ "$emusToUninstall" == *"Duckstation"* ]]; then
			doUninstallDuck=true
		fi
		if [[ "$emusToUninstall" == *"PPSSPP"* ]]; then
			doUninstallPPSSPP=true
		fi
		if [[ "$emusToUninstall" == *"Yuzu"* ]]; then
			doUninstallYuzu=true
		fi
		if [[ "$emusToUninstall" == *"Cemu"* ]]; then
			doUninstallCemu=true
		fi
		#if [[ "$emusToUninstall" == *"Xenia"* ]]; then
		#	doUninstallXenia=true
		#fi
		if [[ "$emusToUninstall" == *"Xemu"* ]]; then
			doUninstallXemu=true
		fi				
		if [[ "$emusToUninstall" == *"SteamRomManager"* ]]; then
			doUninstallSRM=true
		fi
		if [[ "$emusToUninstall" == *"EmulationStationDE"* ]]; then
			doUninstallESDE=true
		fi		
		
	else
		exit
	fi
	
	#Uninstalling
	if [[ "$doUninstallRA" == true ]]; then
		flatpak uninstall org.libretro.RetroArch
		rm -rf ~/.var/app/org.libretro.RetroArch &>> /dev/null	
	fi
	if [[ "$doUninstallPrimeHacks" == true ]]; then
		flatpak uninstall io.github.shiiion.primehack
		rm -rf ~/.var/app/io.github.shiiion.primehack &>> /dev/null	
	fi
	if [[ "$doUninstallPCSX2" == true ]]; then
		flatpak uninstall net.pcsx2.PCSX2
		rm -rf ~/.var/app/net.pcsx2.PCSX2 &>> /dev/null
	fi
	if [[ "$doUninstallRPCS3" == true ]]; then
		flatpak uninstall net.rpcs3.RPCS3
		rm -rf ~/.var/app/net.rpcs3.RPCS3 &>> /dev/null
	fi
	if [[ "$doUninstallCitra" == true ]]; then
		flatpak uninstall org.citra_emu.citra
		rm -rf ~/.var/app/org.citra_emu.citra &>> /dev/null
	fi
	if [[ "$doUninstallDolphin" == true ]]; then
		flatpak uninstall org.DolphinEmu.dolphin-emu
		rm -rf ~/.var/app/org.DolphinEmu.dolphin-emu &>> /dev/null
	fi
	if [[ "$doUninstallDuck" == true ]]; then
		flatpak uninstall org.duckstation.DuckStation
		rm -rf ~/.var/app/org.duckstation.DuckStation &>> /dev/null
	fi
	if [[ "$doUninstallPPSSPP" == true ]]; then
		flatpak uninstall org.ppsspp.PPSSPP
		rm -rf ~/.var/app/org.ppsspp.PPSSPP &>> /dev/null
	fi
	if [[ "$doUninstallYuzu" == true ]]; then
		flatpak uninstall org.yuzu_emu.yuzu
		rm -rf ~/.var/app/org.yuzu_emu.yuzu &>> /dev/null
	fi
	if [[ "$doUninstallCemu" == true ]]; then
		#flatpak uninstall info.cemu.Cemu
		#rm -f ~/.var/app/info.cemu.Cemu &>> /dev/null
		rm -f ~/Emulation/roms/wiiu/* &>> /dev/null
		rm -f /run/media/mmcblk0p1/Emulation/roms/wiiu/* &>> /dev/null
	fi
	#if [[ "$doUninstallXenia" == true ]]; then		
	#	rm -f ~/Emulation/roms/xbox360/* &>> /dev/null
	#	rm -f /run/media/mmcblk0p1/Emulation/roms/xbox360/* &>> /dev/null
	#fi
	if [[ "$doUninstallXemu" == true ]]; then
		flatpak uninstall app.xemu.xemu
		rm -rf ~/.var/app/app.xemu.xemu &>> /dev/null
	fi
	if [[ "$doUninstallSRM" == true ]]; then	
		rm -rf ~/Desktop/Steam-ROM-Manager.AppImage &>> /dev/null
	fi
	if [[ "$doUninstallESDE" == true ]]; then
		rm -rf ~/.emulationstation &>> /dev/null	
	fi
	
	#Emudeck's files	
	rm -rf ~/.steam/steam/controller_base/templates/cemu_controller_config.vdf
	rm -rf ~/.steam/steam/controller_base/templates/citra_controller_config.vdf
	rm -rf ~/.steam/steam/controller_base/templates/pcsx2_controller_config.vdf
	rm -rf ~/emudeck &>> /dev/null	
	rm -rf ~/Desktop/EmuDeckCHD.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeckCHD.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeckUninstall.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeck.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeckSD.desktop &>> /dev/null
	#rm -rf ~/Emulation &>> /dev/null	
	#rm -rf /run/media/mmcblk0p1/Emulation &>> /dev/null	
	
	text="`printf "<b>Done!</b>\n\nWe are sad to see you go and we really hope you give us a chance on the future!\n\n<b>Your roms, saved games and bios are on your Emulation folder, please delete it manually</b>"`"
	
	zenity --info \
			 --title="EmuDeck" \
			 --width=450 \			 
			 --text="${text}" &>> /dev/null	

fi