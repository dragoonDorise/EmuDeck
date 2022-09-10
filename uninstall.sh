#!/bin/bash
doUninstall=false
doUninstallRA=true
doUninstallDolphin=true
doUninstallPCSX2=true
doUninstallRPCS3=true
doUninstallYuzu=true
doUninstallRyujinx=true
doUninstallCitra=true
doUninstallDuck=true
doUninstallCemu=true
doUninstallXemu=true
doUninstallXenia=true
doUninstallPrimeHacks=true
doUninstallPPSSPP=true
doUninstallMame=true
doUninstallSRM=true
doUninstallESDE=true



# LOGFILE="$HOME/Desktop/emudeck-uninstall.log"
# echo "${@}" > "${LOGFILE}" #might as well log out the parameters of the run
# exec > >(tee "${LOGFILE}") 2>&1

#Wellcome
text="`printf "<b>Hi!</b>\nDo you really want to uninstall EmuDeck?\n\nIf you are having issues please go to our Discord or Reddit so we can help you. You can see the links here: https://www.emudeck.com/#download"`"

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

clear

if [ "$doUninstall" == true ]; then 

	text="`printf "If you want to delete all your Steam Entries for your roms open Steam Rom Manager now before we uninstall it.\n\nOnce Steam Rom Manager is launched, go to Settings and select <b>Remove All added app entries</b>\n\nThen close it to continue the uninstall proccess"`"

	zenity --question \
		 --title="EmuDeck" \
		 --width=450 \
		 --ok-label="Yes" \
		 --cancel-label="No" \
		 --text="${text}" 2>/dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		kill -15 "$(pidof steam)"
		"~/Emulation/tools/srm/Steam-ROM-Manager.AppImage"
		"/run/media/mmcblk0p1/Emulation/tools/srm/Steam-ROM-Manager.AppImage"
		
				
	else		
		echo -e "No" 2>/dev/null
	fi

	
	#Emulator selector
	text="`printf " <b>This will delete EmuDeck , all the installed emulators and all of its configuration files, bios and saved games</b>\n\n You can keep the Emulators installed, tell me which ones you want to <b>keep</b>.\n\nIf you select none of them, everything will be deleted except your roms, if you wanna keep your saved games go to the Emulation/saves folder <b>now</b> and make a backup of its contents"`"

	emusToUninstall=$(zenity --list \
				--title="EmuDeck" \
				--height=500 \
				--width=250 \
				--ok-label="OK" \
				--cancel-label="Exit" \
				--text="${text}" \
				--checklist \
				--column="" \
				--column="Keep this emulator and its configuration" \
				1 "RetroArch"\
				2 "PrimeHack" \
				3 "PCSX2" \
				4 "RPCS3" \
				5 "Citra" \
				6 "Dolphin" \
				7 "Duckstation" \
				8 "PPSSPP" \
				9 "Yuzu" \
				10 "Ryujinx" \
				11 "Xemu" \
				12 "Cemu" \
				12 "Mame" )
	ans=$?	
	if [ $ans -eq 0 ]; then
		
		if [[ "$emusToUninstall" == *"RetroArch"* ]]; then
			doUninstallRA=false
		fi
		if [[ "$emusToUninstall" == *"PrimeHack"* ]]; then
			doUninstallPrimeHacks=false
		fi
		if [[ "$emusToUninstall" == *"PCSX2"* ]]; then
			doUninstallPCSX2=false
		fi
		if [[ "$emusToUninstall" == *"RPCS3"* ]]; then
			doUninstallRPCS3=false
		fi
		if [[ "$emusToUninstall" == *"Citra"* ]]; then
			doUninstallCitra=false
		fi
		if [[ "$emusToUninstall" == *"Dolphin"* ]]; then
			doUninstallDolphin=false
		fi
		if [[ "$emusToUninstall" == *"Duckstation"* ]]; then
			doUninstallDuck=false
		fi
		if [[ "$emusToUninstall" == *"PPSSPP"* ]]; then
			doUninstallPPSSPP=false
		fi
		if [[ "$emusToUninstall" == *"Yuzu"* ]]; then
			doUninstallYuzu=false
		fi
		if [[ "$emusToUninstall" == *"Ryujinx"* ]]; then
			doUninstallRyujinx=false
		fi
		if [[ "$emusToUninstall" == *"Cemu"* ]]; then
			doUninstallCemu=false
		fi
		#if [[ "$emusToUninstall" == *"Xenia"* ]]; then
		#	doUninstallXenia=false
		#fi
		if [[ "$emusToUninstall" == *"Xemu"* ]]; then
			doUninstallXemu=false
		fi			
		if [[ "$emusToUninstall" == *"Mame"* ]]; then
			doUninstallMame=false
		fi		
		
	else
		exit
	fi
	
	#Uninstalling
	if [[ "$doUninstallRA" == true ]]; then
		flatpak uninstall org.libretro.RetroArch --system -y
		rm -rf ~/.var/app/org.libretro.RetroArch &>> /dev/null	
	fi
	
	if [[ "$doUninstallPrimeHacks" == true ]]; then
		flatpak uninstall io.github.shiiion.primehack --system -y
		rm -rf ~/.var/app/io.github.shiiion.primehack &>> /dev/null	
	fi
	if [[ "$doUninstallPCSX2" == true ]]; then
		flatpak uninstall net.pcsx2.PCSX2 --system -y
		rm -rf ~/Applications/pcsx2-Qt.AppImage &>> /dev/null
		rm -rf ~/.var/app/net.pcsx2.PCSX2 &>> /dev/null
	fi
	if [[ "$doUninstallRPCS3" == true ]]; then
		flatpak uninstall net.rpcs3.RPCS3 --system -y
		rm -rf ~/.var/app/net.rpcs3.RPCS3 &>> /dev/null
	fi
	if [[ "$doUninstallCitra" == true ]]; then
		flatpak uninstall org.citra_emu.citra --system -y
		rm -rf ~/.var/app/org.citra_emu.citra &>> /dev/null
	fi
	if [[ "$doUninstallDolphin" == true ]]; then
		flatpak uninstall org.DolphinEmu.dolphin-emu --system -y
		rm -rf ~/.var/app/org.DolphinEmu.dolphin-emu &>> /dev/null
	fi
	if [[ "$doUninstallDuck" == true ]]; then
		flatpak uninstall org.duckstation.DuckStation --system -y
		rm -rf ~/.var/app/org.duckstation.DuckStation &>> /dev/null
	fi
	if [[ "$doUninstallPPSSPP" == true ]]; then
		flatpak uninstall org.ppsspp.PPSSPP --system -y
		rm -rf ~/.var/app/org.ppsspp.PPSSPP &>> /dev/null
	fi
	if [[ "$doUninstallYuzu" == true ]]; then
		flatpak uninstall org.yuzu_emu.yuzu --system -y
		rm -rf ~/.var/app/org.yuzu_emu.yuzu &>> /dev/null
		rm -rf ~/Applications/yuzu.AppImage &>> /dev/null
	fi
	if [[ "$doUninstallRyujinx" == true ]]; then		
		rm -rf ~/.config/Ryujinx &>> /dev/null
		rm -rf ~/Applications/publish &>> /dev/null
	fi
	if [[ "$doUninstallCemu" == true ]]; then

		rm -f ~/Emulation/roms/wiiu/* &>> /dev/null
		rm -f /run/media/mmcblk0p1/Emulation/roms/wiiu/* &>> /dev/null
	fi

	if [[ "$doUninstallXemu" == true ]]; then
		flatpak uninstall app.xemu.xemu --system -y
		rm -rf ~/.var/app/app.xemu.xemu &>> /dev/null
	fi
	if [[ "$doUninstallMame" == true ]]; then
		flatpak uninstall org.mamedev.MAME --system -y
		rm -rf ~/.var/app/org.mamedev.MAME &>> /dev/null
	fi

	#Emudeck's files	
	rm -rf ~/.steam/steam/controller_base/templates/cemu_controller_config.vdf
	rm -rf ~/.steam/steam/controller_base/templates/citra_controller_config.vdf
	rm -rf ~/.steam/steam/controller_base/templates/pcsx2_controller_config.vdf
	rm -rf ~/.steam/steam/controller_base/templates/duckstation_controller_config.vdf
	rm -rf ~/emudeck &>> /dev/null	
	rm -rf ~/Desktop/EmuDeckCHD.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeckUninstall.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeck.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeckSD.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeckBinUpdate.desktop &>> /dev/null
	rm -rf ~/Desktop/SteamRomManager.desktop &>> /dev/null

	
	rm -rf ~/.local/share/applications/Cemu.desktop &>> /dev/null
	rm -rf ~/.local/share/applications/EmuDeck.desktop &>> /dev/null
	rm -rf ~/.local/share/applications/pcsx2-Qt.desktop &>> /dev/null
	rm -rf ~/.local/share/applications/Ryujinx.desktop &>> /dev/null
	rm -rf ~/.local/share/applications/yuzu.desktop &>> /dev/null
	
	rm -rf ~/Emulation/bios &>> /dev/null
	rm -rf ~/Emulation/hdpacks &>> /dev/null	
	rm -rf ~/Emulation/saves &>> /dev/null	
	rm -rf ~/Emulation/storage &>> /dev/null	
	rm -rf ~/Emulation/tools &>> /dev/null
	
	
	rm -rf /run/media/mmcblk0p1/Emulation/bios &>> /dev/null
	rm -rf /run/media/mmcblk0p1/Emulation/hdpacks &>> /dev/null	
	rm -rf /run/media/mmcblk0p1/Emulation/saves &>> /dev/null	
	rm -rf /run/media/mmcblk0p1/Emulation/storage &>> /dev/null	
	rm -rf /run/media/mmcblk0p1/Emulation/tools &>> /dev/null	

	
	 text="`printf " <b>Done!</b>\n\n We are sad to see you go and we really hope you give us a chance on the future\n\nYour roms are still on your Emulation folder, please delete it manually if you want"`"
		 zenity --info \
				 --title="EmuDeck" \
				 --width="450" \
				 --text="${text}" 2>/dev/null	
				 
	exit

fi