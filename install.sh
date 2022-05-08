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

#DEV MODE
devMode=$1
case $devMode in
  "BETA")
	branch="beta"
  ;;
  "DEV")
	  branch="dev"
	;;  
  *)
	branch="main"
  ;;
esac

#Clean up from previous installations
rm ~/emudek.log &>> /dev/null # This is emudeck's old log file, it's not a typo!
rm -rf ~/dragoonDoriseTools
mkdir -p ~/emudeck
#Creating log file
echo "" > ~/emudeck/emudeck.log

#Mark as second time so we can detect previous users
FOLDER=~/.var/app/io.github.shiiion.primehack/config_bak
if [ -d "$FOLDER" ]; then
	echo "" > ~/emudeck/.finished
fi
sleep 1
SECONDTIME=~/emudeck/.finished

#Exper mode off by default
expert=false

#Update all systems by default
doUpdateRA=true
doUpdateDolphin=true
doUpdatePCSX2=true
doUpdateRPCS3=true
doUpdateYuzu=true
doUpdateCitra=true
doUpdateDuck=true
doUpdateCemu=true
#doUpdateXenia=true
doUpdateRyujinx=true
doUpdatePrimeHacks=true
doUpdatePPSSPP=true
doUpdateXemu=true
doUpdateSRM=true
#doUpdateMelon=true

#Install all systems by default
doInstallSRM=true
doInstallESDE=true
doInstallRA=false
doInstallDolphin=false
doInstallPCSX2=false
doInstallRPCS3=false
doInstallYuzu=false
doInstallCitra=false
doInstallDuck=false
doInstallCemu=false
#doInstallXenia=false
doInstallPrimeHacks=false
doInstallPPSSPP=false
doInstallXemu=false
#doInstallMelon=false
doInstallCHD=false
doInstallPowertools=false
installString='Installing'

#Default RetroArch configuration 
RABezels=true
RAautoSave=false
SNESAR=43

#Default widescreen
duckWide=true
DolphinWide=true
DreamcastWide=true
BeetleWide=true

#Default installation folders
emulationPath=~/Emulation/
romsPath=~/Emulation/roms/
toolsPath=~/Emulation/tools/
biosPath=~/Emulation/bios/
savesPath=~/Emulation/saves/

#Functions
setESDEEmus(){		
	emu=$1
	system=$2
	FILE=~/.emulationstation/gamelists/$system/gamelist.xml
	if [ ! -f "$FILE" ]; then
		mkdir -p ~/.emulationstation/gamelists/$system && cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/gamelists/$system/gamelist.xml $FILE
	else
		alternativeEmu=$(grep -rnw $FILE -e 'alternativeEmulator')
		if [[ $alternativeEmu == '' ]]; then
			echo "<alternativeEmulator><label>$emu</label></alternativeEmulator>" >> $FILE
		fi
	fi
}

clear
echo -ne "${BOLD}Downloading files from $branch channel...${NONE}"
sleep 5

#We create all the needed folders for installation
mkdir -p dragoonDoriseTools
mkdir -p dragoonDoriseTools/EmuDeck
cd dragoonDoriseTools



git clone https://github.com/dragoonDorise/EmuDeck.git ~/dragoonDoriseTools/EmuDeck &>> ~/emudeck/emudeck.log
if [ ! -z "$devMode" ]; then
	cd ~/dragoonDoriseTools/EmuDeck
	git checkout $branch &>> ~/emudeck/emudeck.log
fi

FOLDER=~/dragoonDoriseTools/EmuDeck
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
else
	echo -e ""
	echo -e "${RED}We couldn't download the needed files, exiting in a few seconds${NONE}"
	echo -e "Please close this window and try again in a few minutes"
	sleep 999999
	exit
fi
clear
cat ~/dragoonDoriseTools/EmuDeck/logo.ans
version=$(cat ~/dragoonDoriseTools/EmuDeck/version.md)
echo -e "${BOLD}EmuDeck ${version}${NONE}"
echo -e ""
cat ~/dragoonDoriseTools/EmuDeck/latest.md
#
# Installation mode selection
#

text="`printf "<b>Hi!</b>\nDo you want to run EmuDeck on Easy or Expert mode?\n\n<b>Easy Mode</b> takes care of everything for you, it is an unattended installation.\n\n<b>Expert mode</b> gives you a bit more of control on how EmuDeck configures your system like giving you the option to install PowerTools or keep your custom configurations per Emulator"`"
zenity --question \
		 --title="EmuDeck" \
		 --width=250 \
		 --ok-label="Expert Mode" \
		 --cancel-label="Easy Mode" \
		 --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	expert=true
else
	expert=false
fi

#
#Storage Selection
#

text="Do you want to install your roms on your SD Card or on your Internal Storage?"
zenity --question \
		 --title="EmuDeck" \
		 --width=250 \
		 --ok-label="SD Card" \
		 --cancel-label="Internal Storage" \
		 --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	echo "Storage: SD" &>> ~/emudeck/emudeck.log
	destination="SD"
	echo "" > ~/emudeck/.SD
else
	echo "Storage: INTERNAL" &>> ~/emudeck/emudeck.log
	destination="INTERNAL"
fi

#
#SD Card detection
#

if [ $destination == "SD" ]; then
	#check dev to see if sd card is inserted and has a partition	
	if [ -b "/dev/mmcblk0p1" ]; then	
		#test if card is writable and linkable
		sdCardFull="$(findmnt -n --raw --evaluate --output=target -S /dev/mmcblk0p1)"
		echo "SD Card found; installing to $sdCardFull">> ~/emudeck/emudeck.log
		touch $sdCardFull/testwrite
		if [ ! -f  $sdCardFull/testwrite ]; then
				text="`printf "<b>SD Card not writable</b>\nMake sure your SD Card is writable"`"
				zenity --error \
				--title="SDCard Error" \
				--width=400 \
				--text="${text}" &>> /dev/null
				exit
		else
			echo "SD Card writable" &>> ~/emudeck/emudeck.log
		fi
		ln -s $sdCardFull/testwrite $sdCardFull/testwrite.link
		if [ ! -f  $sdCardFull/testwrite.link ]; then
				text="`printf "<b>Your SD Card is not compatible with EmuDeck.</b>\nMake sure to use a supported filesystem like EXT4. Formatting your SD Card from SteamUI will fix this.\n\n Go back to Gaming Mode, Settings, System and select Format SD Card there. This will delete all your SD contents."`"
				zenity --error \
				--title="SDCard Error" \
				--width=400 \
				--text="${text}" &>> /dev/null
				rm -f "$sdCardFull/testwrite"
				exit
		else
			echo "Symlink creation succeeded" &>> ~/emudeck/emudeck.log
		fi
		rm -f "$sdCardFull/testwrite" "$sdCardFull/testwrite.link"
	else
		text="`printf "<b>SD Card not detected</b>\nMake sure your SD Card is inserted and start again the installation"`"
		zenity --error \
				--title="SDCard Error" \
				--width=400 \
				--text="${text}" &>> /dev/null
		exit
	fi
	
	#New paths for SD cards
	emulationPath="${sdCardFull}/Emulation/"
	romsPath="${sdCardFull}/Emulation/roms/"
	toolsPath="${sdCardFull}/Emulation/tools/"
	biosPath="${sdCardFull}/Emulation/bios/"
	savesPath="${sdCardFull}/Emulation/saves/"
	ESDEscrapData="${sdCardFull}/Emulation/tools/downloaded_media"

fi

mkdir -p "$emulationPath"
mkdir -p "$toolsPath"launchers 
mkdir -p "$savesPath"

#Cleanup for old users
find "$romsPath" -name "readme.md" -type f -delete &>> ~/emudeck/emudeck.log


#
# Start of Expert mode configuration
# The idea is that Easy mode is unatended, so everything that's out
# out of the ordinary has to had its flag enabled/disabled on Expert mode
#	

if [ $expert == true ]; then


	#CHDMAN	
	text="`printf "Do you want to install our tool to convert iso, gdi and cue to CHD format?\n\n The CHD format allows to have one single file insted of multiple and the final file takes up to 50%% less space"`"
	zenity --question \
			 --title="EmuDeck" \
			 --width=250 \
			 --ok-label="Yes" \
			 --cancel-label="No" \
			 --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		doInstallCHD=true
	else
		doInstallCHD=false
	fi	
	
	#Powertools
	text=""
	text="`printf "Do you want to install Powertools? This can improve Emulators like Yuzu or Dolphin. You will need to create a password for your deck linux desktop user. PowerTools only has touch support, you can control it using the controller\n\n<b>Do not use this if you don not have basic Linux Terminal knowlegde</b>"`"
	zenity --question \
			 --title="EmuDeck" \
			 --width=250 \
			 --ok-label="Yes" \
			 --cancel-label="No" \
			 --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		doInstallPowertools=true
		
	else
		doInstallPowertools=false
	fi	

	#SRM Update selector	
	text="Do you want to update Steam Rom Manager?"
	zenity --question \
			 --title="EmuDeck" \
			 --width=250 \
			 --ok-label="Yes" \
			 --cancel-label="No" \
			 --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		doInstallSRM=true
	else
		doInstallSRM=false
	fi	
		
	#ESDE Install selector	
	text="Do you want to install <span weight=\"bold\" foreground=\"red\">EmulationStation DE</span> and all of its RetroArch cores?"
	zenity --question \
			 --title="EmuDeck" \
			 --width=250 \
			 --ok-label="Yes" \
			 --cancel-label="No" \
			 --text="${text}" &>> /dev/null
	ans=$?	

	if [ $ans -eq 0 ]; then
		doInstallESDE=true
	else
		doInstallESDE=false
	fi
	clear
	#Emulator selector
	text="`printf "What emulators do you want to install?"`"
	emusToInstall=$(zenity --list \
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
				10 "Cemu" \
				11 "Xemu")
	clear
	ans=$?	
	if [ $ans -eq 0 ]; then
		
		if [[ "$emusToInstall" == *"RetroArch"* ]]; then
			doInstallRA=true
		fi
		if [[ "$emusToInstall" == *"PrimeHack"* ]]; then
			doInstallPrimeHacks=true
		fi
		if [[ "$emusToInstall" == *"PCSX2"* ]]; then
			doInstallPCSX2=true
		fi
		if [[ "$emusToInstall" == *"RPCS3"* ]]; then
			doInstallRPCS3=true
		fi
		if [[ "$emusToInstall" == *"Citra"* ]]; then
			doInstallCitra=true
		fi
		if [[ "$emusToInstall" == *"Dolphin"* ]]; then
			doInstallDolphin=true
		fi
		if [[ "$emusToInstall" == *"Duckstation"* ]]; then
			doInstallDuck=true
		fi
		if [[ "$emusToInstall" == *"PPSSPP"* ]]; then
			doInstallPPSSPP=true
		fi
		if [[ "$emusToInstall" == *"Yuzu"* ]]; then
			doInstallYuzu=true
		fi
		if [[ "$emusToInstall" == *"Cemu"* ]]; then
			doInstallCemu=true
		fi
		if [[ "$emusToInstall" == *"Xemu"* ]]; then
			doInstallXemu=true
		fi
		#if [[ "$emusToInstall" == *"Xenia"* ]]; then
		#	doInstallXenia=true
		#fi
		#if [[ "$emusToInstall" == *"MelonDS"* ]]; then
		#	doInstallMelon=true
		#fi
		
		
	else
		exit
	fi
	
	#We force new Cemu install if we detect an older version exists
	DIR=$romsPath/wiiu/roms/
	if [ -d "$DIR" ]; then	
		doInstallCemu=true	
	fi

	FILE=~/emudeck/.custom
	if [ -f "$FILE" ]; then
		FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg
			if [ -d "$FILE" ]; then	
			text="Do you want to use your previous RetroArch customization?"
			zenity --question \
				 	--title="EmuDeck" \
				 	--width=250 \
				 	--ok-label="Yes" \
				 	--cancel-label="No" \
				 	--text="${text}" &>> /dev/null
			ans=$?
			if [ $ans -eq 0 ]; then
				echo "CustomRemain: Yes" &>> ~/emudeck/emudeck.log
				
				#We set the flas if we have created the .files before.
				#if .file exists then the flag is true for that particular question
				FILEBEZELS=~/emudeck/.bezels		
				FILESAVE=~/emudeck/.autosave
				
				if [ -f "$FILEBEZELS" ]; then
					RABezels=true
				else
					RABezels=false
				fi
				
				if [ -f "$FILESAVE" ]; then
					RAautoSave=true
				else
					RAautoSave=false
				fi
							
			else
				echo "CustomRemain: No" &>> ~/emudeck/emudeck.log
				#We reset everything
				rm ~/emudeck/.custom &>> /dev/null
				rm ~/emudeck/.bezels &>> /dev/null
				rm ~/emudeck/.autosave &>> /dev/null			
			fi
		fi
	fi
	
	CUSTOM=~/emudeck/.custom
	
	FILEBEZELS=~/emudeck/.bezels
	if [ ! -f "$CUSTOM" ] && [ ! -f "$FILEBEZELS" ]; then
		
		text="Do you want to use Bezels (Overlays) on RetroArch systems?"
		zenity --question \
				 --title="EmuDeck" \
				 --width=250 \
				 --ok-label="Yes" \
				 --cancel-label="No" \
				 --text="${text}" &>> /dev/null
		ans=$?
		if [ $ans -eq 0 ]; then
			echo "Overlays: Yes" &>> ~/emudeck/emudeck.log
			RABezels=true
			echo "" > ~/emudeck/.bezels
		else
			echo "Overlays: No" &>> ~/emudeck/emudeck.log
			RABezels=false
		fi
		
	fi
	FILESAVE=~/emudeck/.autosave
	if [ ! -f "$CUSTOM" ] && [ ! -f "$FILESAVE" ]; then	
		raConfigFile=~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg
		text="Do you want to use auto save and auto load for RetroArch systems?"
		zenity --question \
				 --title="EmuDeck" \
				 --width=250 \
				 --ok-label="Yes" \
				 --cancel-label="No" \
				 --text="${text}" &>> /dev/null
		ans=$?
		if [ $ans -eq 0 ]; then
			echo "AutoSaveLoad: Yes" &>> ~/emudeck/emudeck.log
			RAautoSave=true
			echo "" > ~/emudeck/.autosave
		else
			echo "AutoSaveLoad: No" &>> ~/emudeck/emudeck.log
			RAautoSave=false
		fi
	fi
	
	#SNES Aspect Ratio	
	text="`printf "What SNES Aspect ratio do you want to use?\n\n<b>4:3</b> Classic CRT TV\n\n<b>8:7</b> Real SNES Internal resolution"`"
	zenity --question \
			 --title="EmuDeck" \
			 --width=250 \
			 --ok-label="4:3" \
			 --cancel-label="8:7" \
			 --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		SNESAR=43		
	else
		SNESAR=87		
	fi	
			
	#Emulators screenHacks
	text="`printf "We use 16:9 widescreen hacks on some emulators, if you want them to have the original 4:3 aspect ratio please select them on the following list"`"
	wideToInstall=$(zenity --list \
				--title="EmuDeck" \
				--height=500 \
				--width=250 \
				--ok-label="OK" \
				--cancel-label="Exit" \
				--text="${text}" \
				--checklist \
				--column="" \
				--column="Emulator" \
				1 "Dolphin" \
				2 "Duckstation" \
				3 "BeetlePSX"
				4 "Dreamcast")
	clear
	ans=$?	
	if [ $ans -eq 0 ]; then
		
		if [[ "$wideToInstall" == *"Duckstation"* ]]; then
			duckWide=false
		fi
		if [[ "$wideToInstall" == *"Dolphin"* ]]; then
			DolphinWide=false
		fi
		if [[ "$wideToInstall" == *"Dreamcast"* ]]; then
			DreamcastWide=false
		fi		
		if [[ "$wideToInstall" == *"BeetlePSX"* ]]; then
			BeetleWide=true
		fi				
				
		
	else		
		exit		
	fi			
	
	#We mark we've made a custom configuration for future updates
	echo "" > ~/emudeck/.custom
	
	
	# Configuration that only appplies to previous users
	if [ -f "$SECONDTIME" ]; then
		#We make sure all the emus can write its saves outside its own folders.
		#Also needed for certain emus to open certain menus for adding rom directories in the front end.
		#flatpak override net.pcsx2.PCSX2 --filesystem=host --user
		flatpak override io.github.shiiion.primehack --filesystem=host --user
		flatpak override net.rpcs3.RPCS3 --filesystem=host --user
		flatpak override org.citra_emu.citra --filesystem=host --user
		flatpak override org.DolphinEmu.dolphin-emu --filesystem=host --user
		#flatpak override org.duckstation.DuckStation --filesystem=host --user
		#flatpak override org.libretro.RetroArch --filesystem=host --user
		#flatpak override org.ppsspp.PPSSPP --filesystem=host --user
		flatpak override org.yuzu_emu.yuzu --filesystem=host --user
		flatpak override app.xemu.xemu --filesystem=/run/media:rw --user
		
		installString='Updating'
			
		text="`printf "<b>EmuDeck will overwrite the following Emulators configurations</b> \nWhich systems do you want me to keep its current configuration <b>untouched</b>?\nWe recomend to keep all of them unchecked so everything gets updated so any possible bug can be fixed.\n If you want to mantain any custom configuration on some emulator select its name on this list"`"
		emusToReset=$(zenity --list \
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
							10 "Cemu" \
							11 "Xemu" \
							12 "SRM")
		clear
		cat ~/dragoonDoriseTools/EmuDeck/logo.ans
		echo -e "${BOLD}EmuDeck ${version}${NONE}"
		ans=$?
		if [ $ans -eq 0 ]; then
			
			if [[ "$emusToReset" == *"RetroArch"* ]]; then
				doUpdateRA=false
			fi
			if [[ "$emusToReset" == *"PrimeHack"* ]]; then
				doUpdatePrimeHacks=false
			fi
			if [[ "$emusToReset" == *"PCSX2"* ]]; then
				doUpdatePCSX2=false
			fi
			if [[ "$emusToReset" == *"RPCS3"* ]]; then
				doUpdateRPCS3=false
			fi
			if [[ "$emusToReset" == *"Citra"* ]]; then
				doUpdateCitra=false
			fi
			if [[ "$emusToReset" == *"Dolphin"* ]]; then
				doUpdateDolphin=false
			fi
			if [[ "$emusToReset" == *"Duckstation"* ]]; then
				doUpdateDuck=false
			fi
			if [[ "$emusToReset" == *"PPSSPP"* ]]; then
				doUpdatePPSSPP=false
			fi
			if [[ "$emusToReset" == *"Yuzu"* ]]; then
				doUpdateYuzu=false
			fi
			if [[ "$emusToReset" == *"Cemu"* ]]; then
				doUpdateCemu=false
			fi
			if [[ "$emusToReset" == *"Xemu"* ]]; then
				doUpdateXemu=false
			fi
			#if [[ "$emusToReset" == *"Xenia"* ]]; then
			#	doUpdateXenia=false
			#fi
			#if [[ "$emusToReset" == *"MelonDS"* ]]; then
			#	doUpdateMelon=false
			#fi
			if [[ "$emusToReset" == *"SRM"* ]]; then
				doUpdateSRM=false
			fi
			
			
		else
			echo ""
		fi
		
	fi
	
else

	doInstallRA=true
	doInstallDolphin=true
	doInstallPCSX2=true
	doInstallRPCS3=true
	doInstallYuzu=true
	doInstallCitra=true
	doInstallDuck=true
	doInstallCemu=true
	#doInstallXenia=true
	doInstallPrimeHacks=true
	doInstallPPSSPP=true
	doInstallXemu=true
	#doInstallMelon=true

fi # end Expert if

##
##
## End of configuration
##	
##
	
	
	
	
##
##
## Start of installation
##	
##


#ESDE Installation
if [ $doInstallESDE == true ]; then
	echo "ESDE: Yes" &>> ~/emudeck/emudeck.log
	echo -e "${BOLD}${installString} EmulationStation Desktop Edition${NONE}"
	curl https://gitlab.com/leonstyhre/emulationstation-de/-/raw/master/es-app/assets/latest_steam_deck_appimage.txt --output "$toolsPath"/latesturl.txt >> ~/emudeck/emudeck.log
	latestURL=$(grep "https://gitlab" "$toolsPath"/latesturl.txt)
	curl $latestURL --output "$toolsPath"/EmulationStation-DE-x64_SteamDeck.AppImage >> ~/emudeck/emudeck.log
	rm "$toolsPath"/latesturl.txt
	chmod +x "$toolsPath"/EmulationStation-DE-x64_SteamDeck.AppImage	
fi

#We check if we have scrapped data on ESDE so we can move it to the SD card
#We do this wether the user wants to install ESDE or not to account for old users that might have ESDE already installed and won't update
if [ $destination == "SD" ]; then		
	#Symlink already created?
	if [ ! -d "$ESDEscrapData" ]; then		
		echo -e ""
		echo -e "Moving EmulationStation downloaded media to the SD Card"			
		echo -e ""
		mv ~/.emulationstation/downloaded_media $ESDEscrapData && rm -rf ~/.emulationstation/downloaded_media && ln -sn $ESDEscrapData ~/.emulationstation/downloaded_media			
	fi			
fi

#SRM Installation
if [ $doInstallSRM == true ]; then
	echo -e "${BOLD}${installString} Steam Rom Manager${NONE}"
	rm -f ~/Desktop/Steam-ROM-Manager-2.3.29.AppImage &>> ~/emudeck/emudeck.log
	curl -L "$(curl -s https://api.github.com/repos/SteamGridDB/steam-rom-manager/releases/latest | grep -E 'browser_download_url.*AppImage' | grep -ve 'i386' | cut -d '"' -f 4)" > ~/Desktop/Steam-ROM-Manager.AppImage
	#Nova fix'
	chmod +x ~/Desktop/Steam-ROM-Manager.AppImage
fi
	

#Emulators Installation
if [ $doInstallPCSX2 == "true" ]; then
	echo -e "Installing PCSX2"
	flatpak install flathub net.pcsx2.PCSX2 -y --system	&>> ~/emudeck/emudeck.log
	flatpak override net.pcsx2.PCSX2 --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run net.pcsx2.PCSX2" > "${toolsPath}"launchers/pcsx2.sh
	chmod +x "${toolsPath}"launchers/pcsx2.sh	
fi
if [ $doInstallPrimeHacks == "true" ]; then
	echo -e "Installing PrimeHack"
	flatpak install flathub io.github.shiiion.primehack -y --system &>> ~/emudeck/emudeck.log
	flatpak override io.github.shiiion.primehack --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run io.github.shiiion.primehack" > "${toolsPath}"launchers/primehack.sh
	chmod +x "${toolsPath}"launchers/primehack.sh	
fi
if [ $doInstallRPCS3 == "true" ]; then
	echo -e "Installing RPCS3"
	flatpak install flathub net.rpcs3.RPCS3 -y --system &>> ~/emudeck/emudeck.log
	flatpak override net.rpcs3.RPCS3 --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run net.rpcs3.RPCS3" > "${toolsPath}"launchers/rpcs3.sh
	chmod +x "${toolsPath}"launchers/rpcs3.sh	
fi
if [ $doInstallCitra == "true" ]; then
	echo -e "Installing Citra"
	flatpak install flathub org.citra_emu.citra -y --system &>> ~/emudeck/emudeck.log
	flatpak override org.citra_emu.citra --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run org.citra_emu.citra" > "${toolsPath}"launchers/citra.sh
	chmod +x "${toolsPath}"launchers/citra.sh	
fi
if [ $doInstallDolphin == "true" ]; then
	echo -e "Installing Dolphin"
	flatpak install flathub org.DolphinEmu.dolphin-emu -y --system &>> ~/emudeck/emudeck.log
	flatpak override org.DolphinEmu.dolphin-emu --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run org.DolphinEmu.dolphin-emu" > "${toolsPath}"launchers/dolphin-emu.sh
	chmod +x "${toolsPath}"launchers/dolphin-emu.sh	
fi
if [ $doInstallDuck == "true" ]; then
	echo -e "Installing DuckStation"
	flatpak install flathub org.duckstation.DuckStation -y --system &>> ~/emudeck/emudeck.log
	#flatpak override org.duckstation.DuckStation --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run org.duckstation.DuckStation" > "${toolsPath}"launchers/duckstation.sh
	chmod +x "${toolsPath}"launchers/duckstation.sh	
fi
if [ $doInstallRA == "true" ]; then
	echo -e "Installing RetroArch"
	flatpak install flathub org.libretro.RetroArch -y --system &>> ~/emudeck/emudeck.log
	#flatpak override org.libretro.RetroArch --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run org.libretro.RetroArch" > "${toolsPath}"launchers/RetroArch.sh
	chmod +x "${toolsPath}"launchers/RetroArch.sh	
fi
if [ $doInstallPPSSPP == "true" ]; then
	echo -e "Installing PPSSPP"
	flatpak install flathub org.ppsspp.PPSSPP -y --system &>> ~/emudeck/emudeck.log
	#flatpak override org.ppsspp.PPSSPP --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run org.ppsspp.PPSSPP" > "${toolsPath}"launchers/ppsspp.sh
	chmod +x "${toolsPath}"launchers/ppsspp.sh
fi
if [ $doInstallYuzu == "true" ]; then
	echo -e "Installing Yuzu"
	flatpak install flathub org.yuzu_emu.yuzu -y --system &>> ~/emudeck/emudeck.log
	flatpak override org.yuzu_emu.yuzu --filesystem=host --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run org.yuzu_emu.yuzu" > "${toolsPath}"launchers/yuzu.sh
	chmod +x "${toolsPath}"launchers/yuzu.sh
fi
if [ $doInstallXemu == "true" ]; then
	echo -e "Installing Xemu"
	flatpak install flathub app.xemu.xemu -y --system &>> ~/emudeck/emudeck.log
	flatpak override app.xemu.xemu --filesystem=/run/media:rw --user
	#write out launcher
	echo "#!/bin/sh
	/usr/bin/flatpak run app.xemu.xemu" > "${toolsPath}"launchers/xemu.sh
	chmod +x "${toolsPath}"launchers/xemu.sh
fi
#if [ $doInstallMelon == "true" ]; then
#	echo -e "Installing MelonDS"
#	flatpak install flathub net.kuribo64.melonDS -y --system &>> ~/emudeck/emudeck.log
#fi
echo -e ""


##Generate rom folders
if [ $destination == "SD" ]; then
	echo -ne "${BOLD}Creating roms folder in your SD Card...${NONE}"
else
	echo -ne "${BOLD}Creating roms folder in your home folder...${NONE}"
fi
mkdir -p "$romsPath"
mkdir -p "$biosPath"
mkdir -p "$biosPath"/yuzu/
sleep 3
rsync -r ~/dragoonDoriseTools/EmuDeck/roms/ "$romsPath" &>> ~/emudeck/emudeck.log
echo -e "${GREEN}OK!${NONE}"


#Cemu - We need to install Cemu after creating the Roms folders!
if [ $doInstallCemu == "true" ]; then
	echo -e "Installing Cemu"		
	FILE="${romsPath}/wiiu/Cemu.exe"	
	if [ -f "$FILE" ]; then
		echo "" &>> /dev/null
	else
		curl https://cemu.info/releases/cemu_1.26.2.zip --output $romsPath/wiiu/cemu_1.26.2.zip &>> ~/emudeck/emudeck.log
		mkdir -p $romsPath/wiiu/tmp
		unzip -o "$romsPath"/wiiu/cemu_1.26.2.zip -d "$romsPath"/wiiu/tmp &>> ~/emudeck/emudeck.log
		mv "$romsPath"/wiiu/tmp/*/* "$romsPath"/wiiu &>> ~/emudeck/emudeck.log
		rm -rf "$romsPath"/wiiu/tmp &>> ~/emudeck/emudeck.log
		rm -f "$romsPath"/wiiu/cemu_1.26.2.zip &>> ~/emudeck/emudeck.log		
	fi

	if ! [ -f "${toolsPath}"launchers/cemu.sh ]; then
		cp ~/dragoonDoriseTools/EmuDeck/tools/launchers/cemu.sh "${toolsPath}"launchers/cemu.sh
		sed -i 's|/run/media/mmcblk0p1/Emulation/roms/wiiu|${romsPath}wiiu|' "${toolsPath}"launchers/cemu.sh
		chmod +x ${toolsPath}/launchers/cemu.sh
	fi
	#Commented until we get CEMU flatpak working
	#echo -e "${BOLD}EmuDeck will add Witherking25's flatpak repo to your Discorver App.this is required for cemu now${NONE}"	
	#flatpak remote-add --user --if-not-exists withertech https://repo.withertech.com/flatpak/withertech.flatpakrepo &>> ~/emudeck/emudeck.log
	#flatpak install withertech info.cemu.Cemu -y &>> ~/emudeck/emudeck.log
	#flatpak install flathub org.winehq.Wine -y &>> ~/emudeck/emudeck.log
	#
	##We move roms to the new path
	#DIR=$romsPath/wiiu/roms/
	#if [ -d "$DIR" ]; then			
	#	echo -e "Moving your WiiU games and configuration to the new Cemu...This might take a while"
	#	mv $romsPath/wiiu/roms/ $romsPath/wiiutemp &>> ~/emudeck/emudeck.log
	#	mv $romsPath/wiiu/Cemu.exe $romsPath/wiiu/Cemu.bak &>> ~/emudeck/emudeck.log
	#	rsync -ri $romsPath/wiiu/ ~/.var/app/info.cemu.Cemu/data/cemu/ &>> ~/emudeck/emudeck.log
	#	mv $romsPath/wiiu/ $romsPath/wiiu_delete_me &>> ~/emudeck/emudeck.log
	#	mv $romsPath/wiiutemp/ $romsPath/wiiu/ &>> ~/emudeck/emudeck.log
	#	
	#	zenity --info \
	#	   --title="EmuDeck" \
	#	   --width=250 \
	#	   --text="We have updated your CEMU installation, you will need to open Steam Rom Manager and add your Wii U games again. This time you don't need to set CEMU to use Proton ever again :)" &>> /dev/null
	#	   
	#fi
	
fi

#Xenia - We need to install Xenia after creating the Roms folders!
#if [ $doInstallXenia == "true" ]; then
#	echo -e "Installing Xenia"		
#	FILE="${romsPath}/xbox360/xenia.exe"	
#	if [ -f "$FILE" ]; then
#		echo "" &>> /dev/null
#	else
#		curl -L https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip --output $romsPath/xbox360/xenia_master.zip &>> ~/emudeck/emudeck.log
#		mkdir -p $romsPath/xbox360/tmp
#		unzip -o "$romsPath"/xbox360/xenia_master.zip -d "$romsPath"/xbox360/tmp &>> ~/emudeck/emudeck.log
#		mv "$romsPath"/xbox360/tmp/* "$romsPath"/xbox360 &>> ~/emudeck/emudeck.log
#		rm -rf "$romsPath"/xbox360/tmp &>> ~/emudeck/emudeck.log
#		rm -f "$romsPath"/xbox360/xenia_master.zip &>> ~/emudeck/emudeck.log		
#	fi
#	
#fi

#Steam RomManager Config

if [ $doUpdateSRM == true ]; then
	echo -ne "${BOLD}Configuring Steam Rom Manager...${NONE}"
	mkdir -p ~/.config/steam-rom-manager/userData/
	cp ~/dragoonDoriseTools/EmuDeck/configs/steam-rom-manager/userData/userConfigurations.json ~/.config/steam-rom-manager/userData/userConfigurations.json
	sleep 3
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.config/steam-rom-manager/userData/userConfigurations.json
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" ~/.config/steam-rom-manager/userData/userConfigurations.json
	echo -e "${GREEN}OK!${NONE}"
fi

#ESDE Config
echo -ne "${BOLD}Configuring EmulationStation DE...${NONE}"
mkdir -p ~/.emulationstation/
#Cemu (Proton) commented until we get it right
#mkdir -p ~/.emulationstation/custom_systems/
#cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/custom_systems/es_systems.xml ~/.emulationstation/custom_systems/es_systems.xml
#sed -i "s|/run/media/mmcblk0p1/Emulation/tools/launchers/cemu.sh|${toolsPath}launchers/cemu.sh|" ~/.emulationstation/custom_systems/es_systems.xml
#Commented until we get CEMU flatpak working
#rsync -r ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/ ~/.emulationstation/
cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/es_settings.xml ~/.emulationstation/es_settings.xml
sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.emulationstation/es_settings.xml
#sed -i "s|name=\"ROMDirectory\" value=\"/name=\"ROMDirectory\" value=\"${romsPathSed}/g" ~/.emulationstation/es_settings.xml
echo -e "${GREEN}OK!${NONE}"

#ESDE default emulators
mkdir -p  ~/.emulationstation/gamelists/
setESDEEmus 'Genesis Plus GX' gamegear
setESDEEmus 'Gambatte' gb
setESDEEmus 'Gambatte' gbc
setESDEEmus 'Dolphin (Standalone)' gc
setESDEEmus 'PPSSPP (Standalone)' psp
setESDEEmus 'Dolphin (Standalone)' wii
setESDEEmus 'Mesen' nes
	
#Emus config
echo -ne "${BOLD}Configuring Steam Input for emulators..${NONE}"
rsync -r ~/dragoonDoriseTools/EmuDeck/configs/steam-input/ ~/.steam/steam/controller_base/templates/
echo -e "${GREEN}OK!${NONE}"
echo -e "${BOLD}Configuring emulators..${NONE}"
echo -e ""
if [ $doUpdateRA == true ]; then

	mkdir -p ~/.var/app/org.libretro.RetroArch
	mkdir -p ~/.var/app/org.libretro.RetroArch/config
	mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch
	mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch/cores
	raUrl="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
	RAcores=(bsnes_hd_beta_libretro.so flycast_libretro.so gambatte_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_wswan_libretro.so melonds_libretro.so mesen_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nestopia_libretro.so picodrive_libretro.so ppsspp_libretro.so snes9x_libretro.so stella_libretro.so yabasanshiro_libretro.so yabause_libretro.so yabause_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so fbneo_libretro.so bluemsx_libretro.so desmume_libretro.so sameboy_libretro.so gearsystem_libretro.so mednafen_saturn_libretro.so opera_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so puae_libretro.so)
	echo -e "${BOLD}Downloading RetroArch Cores for EmuDeck${NONE}"
	for i in "${RAcores[@]}"
	do
		FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
		if [ -f "$FILE" ]; then
			echo -e "${i}...${YELLOW}Already Downloaded${NONE}"
		else
			curl $raUrl$i.zip --output ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip >> ~/emudeck/emudeck.log
			#rm ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo -e "${i}...${GREEN}Downloaded!${NONE}"
		fi
	done	
	
	if [ $doInstallESDE == true ]; then
		RAcores=(a5200_libretro.so 81_libretro.so atari800_libretro.so bluemsx_libretro.so chailove_libretro.so fbneo_libretro.so freechaf_libretro.so freeintv_libretro.so fuse_libretro.so gearsystem_libretro.so gw_libretro.so hatari_libretro.so lutro_libretro.so mednafen_pcfx_libretro.so mednafen_vb_libretro.so mednafen_wswan_libretro.so mu_libretro.so neocd_libretro.so nestopia_libretro.so nxengine_libretro.so o2em_libretro.so picodrive_libretro.so pokemini_libretro.so prboom_libretro.so prosystem_libretro.so px68k_libretro.so quasi88_libretro.so scummvm_libretro.so squirreljme_libretro.so theodore_libretro.so uzem_libretro.so vecx_libretro.so vice_xvic_libretro.so virtualjaguar_libretro.so x1_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_pce_libretro.so mednafen_pce_fast_libretro.so mednafen_psx_libretro.so mednafen_psx_hw_libretro.so mednafen_saturn_libretro.so mednafen_supafaust_libretro.so mednafen_supergrafx_libretro.so blastem_libretro.so bluemsx_libretro.so bsnes_libretro.so bsnes_mercury_accuracy_libretro.so cap32_libretro.so citra2018_libretro.so citra_libretro.so crocods_libretro.so desmume2015_libretro.so desmume_libretro.so dolphin_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so fbalpha2012_cps1_libretro.so fbalpha2012_cps2_libretro.so fbalpha2012_cps3_libretro.so fbalpha2012_libretro.so fbalpha2012_neogeo_libretro.so fceumm_libretro.so fbneo_libretro.so flycast_libretro.so fmsx_libretro.so frodo_libretro.so gambatte_libretro.so gearboy_libretro.so gearsystem_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so gpsp_libretro.so handy_libretro.so kronos_libretro.so mame2000_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so mesen_libretro.so mesen-s_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nekop2_libretro.so np2kai_libretro.so nestopia_libretro.so parallel_n64_libretro.so pcsx2_libretro.so pcsx_rearmed_libretro.so picodrive_libretro.so ppsspp_libretro.so puae_libretro.so quicknes_libretro.so race_libretro.so sameboy_libretro.so smsplus_libretro.so snes9x2010_libretro.so snes9x_libretro.so stella2014_libretro.so stella_libretro.so tgbdual_libretro.so vbam_libretro.so vba_next_libretro.so vice_x128_libretro.so vice_x64_libretro.so vice_x64sc_libretro.so vice_xscpu64_libretro.so yabasanshiro_libretro.so yabause_libretro.so bsnes_hd_beta_libretro.so swanstation_libretro.so)
		echo -e "${BOLD}Downloading RetroArch Cores for EmulationStation DE${NONE}"
		for i in "${RAcores[@]}"
		do
			FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
			if [ -f "$FILE" ]; then
				echo -e "${i}...${YELLOW}Already Downloaded${NONE}"
			else
				curl $raUrl$i.zip --output ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip >> ~/emudeck/emudeck.log
				#rm ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
				echo -e "${i}...${GREEN}Downloaded!${NONE}"
			fi
		done
	fi	
	
	for entry in ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 unzip -o "$entry" -d ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/ &>> ~/emudeck/emudeck.log
	done
	
	for entry in ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 rm -f "$entry" >> ~/emudeck/emudeck.log
	done
	
	raConfigFile=~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg
	FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
	if [ -f "$FILE" ]; then
		echo -e "" &>> /dev/null
	else
		echo -ne "Backing up RA..."
		cp ~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	#mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch/overlays
	
	#Cleaning up cfg files that the user could have created on Expert mode
	find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" | while read f; do rm -f "$f"; done &>> ~/emudeck/emudeck.log
	find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.bak" | while read f; do rm -f "$f"; done &>> ~/emudeck/emudeck.log
	
	rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/ ~/.var/app/org.libretro.RetroArch/config/
	#rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/retroarch/config/ ~/.var/app/org.libretro.RetroArch/config/retroarch/config
	
	sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" $raConfigFile	
	
fi
echo -e ""
echo -ne "${BOLD}Applying Emu configurations...${NONE}"
if [ $doUpdatePrimeHacks == true ]; then
	FOLDER=~/.var/app/io.github.shiiion.primehack/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up PrimeHacks..."
		cp -r ~/.var/app/io.github.shiiion.primehack/config ~/.var/app/io.github.shiiion.primehack/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/io.github.shiiion.primehack/ ~/.var/app/io.github.shiiion.primehack/ &>> ~/emudeck/emudeck.log
fi
if [ $doUpdateDolphin == true ]; then

	# Check if there's an existing MAC address and Analytics ID in the Dolphin config
	#config_path=~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini
	#WirelessMacOld=$(grep -E "^WirelessMac" $config_path | cut -d\= -f2)
	#AnalyticsIDold=$(grep -E "ID ?= ?[0-9a-f]{32}" $config_path | cut -d\= -f2)

	FOLDER=~/.var/app/org.DolphinEmu.dolphin-emu/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up Dolphin..."
		cp -r ~/.var/app/org.DolphinEmu.dolphin-emu/config ~/.var/app/org.DolphinEmu.dolphin-emu/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.DolphinEmu.dolphin-emu/ ~/.var/app/org.DolphinEmu.dolphin-emu/ &>> ~/emudeck/emudeck.log
	
	
	# We add the previous Mac address
	#if [ $AnalyticsIDold != "" ]; then
	#	 # Insert old analytics ID:
	#	 sed -i "s|@@DOLPHIN_ANALYTICS_ID@@|${AnalyticsIDold}|g" ~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini
	#fi
	#
	#if [ $WirelessMacOld != "" ]; then
	#	 # Insert old MAC address:
	#	 sed -i "s|@@WIRELESS_DEVICE_MAC@@|${WirelessMacOld}|g" ~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini
	#fi
		
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/Dolphin.ini
fi
if [ $doUpdatePCSX2 == true ]; then
	FOLDER=~/.var/app/net.pcsx2.PCSX2/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up PCSX2..."
		cp -r ~/.var/app/net.pcsx2.PCSX2/config ~/.var/app/net.pcsx2.PCSX2/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.pcsx2.PCSX2/ ~/.var/app/net.pcsx2.PCSX2/ &>> ~/emudeck/emudeck.log
	#Bios Fix
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios|${biosPath}|g" ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini &>> ~/emudeck/emudeck.log
fi
if [ $doUpdateRPCS3 == true ]; then
	FOLDER=~/.var/app/net.rpcs3.RPCS3/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up RPCS3..."
		cp -r ~/.var/app/net.rpcs3.RPCS3/config ~/.var/app/net.rpcs3.RPCS3/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi

	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.rpcs3.RPCS3/ ~/.var/app/net.rpcs3.RPCS3/ &>> ~/emudeck/emudeck.log
	sed -i 's| $(EmulatorDir)dev_hdd0/| '$savesPath'/rpcs3/dev_hdd0/|g' /home/deck/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml >> ~/emudeck/emudeck.log
	mkdir -p $savesPath/rpcs3/ >> ~/emudeck/emudeck.log
fi
if [ $doUpdateCitra == true ]; then
	FOLDER=~/.var/app/org.citra_emu.citra/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up Citra..."
		cp -r ~/.var/app/org.citra_emu.citra/config ~/.var/app/org.citra_emu.citra/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi

	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.citra_emu.citra/ ~/.var/app/org.citra_emu.citra/ &>> ~/emudeck/emudeck.log
fi
if [ $doUpdateDuck == true ]; then
	FOLDER=~/.var/app/org.duckstation.DuckStation/data_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up DuckStation..."
		cp -r ~/.var/app/org.duckstation.DuckStation/data ~/.var/app/org.duckstation.DuckStation/data_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.duckstation.DuckStation/ ~/.var/app/org.duckstation.DuckStation/ &>> ~/emudeck/emudeck.log
	sleep 3
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios/|${biosPath}|g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini
fi
if [ $doUpdateYuzu == true ]; then
	FOLDER=~/.var/app/org.yuzu_emu.yuzu/config
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up Yuzu..."
		cp -r ~/.var/app/org.yuzu_emu.yuzu/config ~/.var/app/org.yuzu_emu.yuzu/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/ ~/.var/app/org.yuzu_emu.yuzu/ &>> ~/emudeck/emudeck.log
fi
#if [ $doUpdateMelon == true ]; then
#	FOLDER=~/.var/app/net.kuribo64.melonDS/config
#	if [ -d "$FOLDER" ]; then
#		echo "" &>> ~/emudeck/emudeck.log
#	else
#		echo -ne "Backing up MelonDS..."
#		cp -r ~/.var/app/net.kuribo64.melonDS/config ~/.var/app/net.kuribo64.melonDS/config_bak &>> ~/emudeck/emudeck.log
#		echo -e "${GREEN}OK!${NONE}"
#	fi
#	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.kuribo64.melonDS/ ~/.var/app/net.kuribo64.melonDS/ &>> ~/emudeck/emudeck.log
#fi
if [ $doUpdateCemu == true ]; then
	echo "" &>> ~/emudeck/emudeck.log
	#Commented until we get CEMU flatpak working
	#rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/info.cemu.Cemu/ ~/.var/app/info.cemu.Cemu/ &>> ~/emudeck/emudeck.log
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/info.cemu.Cemu/data/cemu/ "$romsPath"/wiiu &>> ~/emudeck/emudeck.log
fi
#if [ $doUpdateXenia == true ]; then
#	echo "" &>> ~/emudeck/emudeck.log
#	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/xenia/ "$romsPath"/xbox360 &>> ~/emudeck/emudeck.log
#fi
if [ $doUpdateRyujinx == true ]; then
	echo "" &>> ~/emudeck/emudeck.log
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.ryujinx.Ryujinx/ ~/.var/app/org.ryujinx.Ryujinx/ &>> ~/emudeck/emudeck.log
fi
if [ $doUpdatePPSSPP == true ]; then
	FOLDER=~/.var/app/org.ppsspp.PPSSPP/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up PPSSPP..."
		cp -r ~/.var/app/org.ppsspp.PPSSPP/config ~/.var/app/org.ppsspp.PPSSPP/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.ppsspp.PPSSPP/ ~/.var/app/org.ppsspp.PPSSPP/ &>> ~/emudeck/emudeck.log
fi
if [ $doUpdateXemu == true ]; then
	FOLDER=~/.var/app/app.xemu.xemu/data/xemu/xemu_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up Xemu..."
		cp -r ~/.var/app/app.xemu.xemu/data/xemu/xemu ~/.var/app/app.xemu.xemu/data/xemu/xemu_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/app.xemu.xemu/ ~/.var/app/app.xemu.xemu/ &>> ~/emudeck/emudeck.log
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios/|${biosPath}|g" ~/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.ini
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios/|${biosPath}|g" ~/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml
	sed -i "s|/run/media/mmcblk0p1/Emulation/saves/|${savesPath}|g" ~/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml
fi
echo -e "${GREEN}OK!${NONE}"

#Symlinks for ESDE compatibility
cd $(echo $romsPath | tr -d '\r') 
ln -sn gamecube gc &>> ~/emudeck/emudeck.log
ln -sn 3ds n3ds &>> ~/emudeck/emudeck.log
ln -sn arcade mamecurrent &>> ~/emudeck/emudeck.log
ln -sn mame mame2003 &>> ~/emudeck/emudeck.log
ln -sn lynx atarilynx &>> ~/emudeck/emudeck.log

#Fixes ESDE
unlink megacd &>> ~/emudeck/emudeck.log
unlink megadrive &>> ~/emudeck/emudeck.log

cd $(echo $biosPath | tr -d '\r')
cd yuzu
ln -sn ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/ ./keys &>> ~/emudeck/emudeck.log
ln -sn ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered/ ./firmware &>> ~/emudeck/emudeck.log

#Fixes repeated Symlinx
cd ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/
unlink keys &>> ~/emudeck/emudeck.log
cd ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered/
unlink registered &>> ~/emudeck/emudeck.log



#
##
##End of installation
##
#


#
##
##Validations
##
#

#PS Bios
PSXBIOS="NULL"
PS2BIOS="NULL"
for entry in $biosPath/*
do
	if [ -f "$entry" ]; then		
		md5=($(md5sum "$entry"))	
		if [[ "$PSXBIOS" != true ]]; then
			PSBios=(239665b1a3dade1b5a52c06338011044 2118230527a9f51bd9216e32fa912842 849515939161e62f6b866f6853006780 dc2b9bf8da62ec93e868cfd29f0d067d 54847e693405ffeb0359c6287434cbef cba733ceeff5aef5c32254f1d617fa62 da27e8b6dab242d8f91a9b25d80c63b8 417b34706319da7cf001e76e40136c23 57a06303dfa9cf9351222dfcbb4a29d9 81328b966e6dcf7ea1e32e55e1c104bb 924e392ed05558ffdb115408c263dccf e2110b8a2b97a8e0b857a45d32f7e187 ca5cfc321f916756e3f0effbfaeba13b 8dd7d5296a650fac7319bce665a6a53c 490f666e1afb15b7362b406ed1cea246 32736f17079d0b2b7024407c39bd3050 8e4c14f567745eff2f0408c8129f72a6 b84be139db3ee6cbd075630aa20a6553 1e68c231d0896b7eadcad1d7d8e76129 b9d9a0286c33dc6b7237bb13cd46fdee 8abc1b549a4a80954addc48ef02c4521 9a09ab7e49b422c007e6d54d7c49b965 b10f5e0e3d9eb60e5159690680b1e774 6e3735ff4c7dc899ee98981385f6f3d0 de93caec13d1a141a40a79f5c86168d6 c53ca5908936d412331790f4426c6c33 476d68a94ccec3b9c8303bbd1daf2810 d8f485717a5237285e4d7c5f881b7f32 fbb5f59ec332451debccf1e377017237 81bbe60ba7a3d1cea1d48c14cbcc647b)
			for i in "${PSBios[@]}"
			do
			if [[ "$md5" == *"${i}"* ]]; then
				PSXBIOS=true
				break
			else
				PSXBIOS=false
			fi
			done	
		fi
		
		if [[ "$PS2BIOS" != true ]]; then
			PS2Bios=(32f2e4d5ff5ee11072a6bc45530f5765 acf4730ceb38ac9d8c7d8e21f2614600 acf9968c8f596d2b15f42272082513d1 b1459d7446c69e3e97e6ace3ae23dd1c d3f1853a16c2ec18f3cd1ae655213308 63e6fd9b3c72e0d7b920e80cf76645cd a20c97c02210f16678ca3010127caf36 8db2fbbac7413bf3e7154c1e0715e565 91c87cb2f2eb6ce529a2360f80ce2457 3016b3dd42148a67e2c048595ca4d7ce b7fa11e87d51752a98b38e3e691cbf17 f63bc530bd7ad7c026fcd6f7bd0d9525 cee06bd68c333fc5768244eae77e4495 0bf988e9c7aaa4c051805b0fa6eb3387 8accc3c49ac45f5ae2c5db0adc854633 6f9a6feb749f0533aaae2cc45090b0ed 838544f12de9b0abc90811279ee223c8 bb6bbc850458fff08af30e969ffd0175 815ac991d8bc3b364696bead3457de7d b107b5710042abe887c0f6175f6e94bb ab55cceea548303c22c72570cfd4dd71 18bcaadb9ff74ed3add26cdf709fff2e 491209dd815ceee9de02dbbc408c06d6 7200a03d51cacc4c14fcdfdbc4898431 8359638e857c8bc18c3c18ac17d9cc3c 352d2ff9b3f68be7e6fa7e6dd8389346 d5ce2c7d119f563ce04bc04dbc3a323e 0d2228e6fd4fb639c9c39d077a9ec10c 72da56fccb8fcd77bba16d1b6f479914 5b1f47fbeb277c6be2fccdd6344ff2fd 315a4003535dfda689752cb25f24785c 312ad4816c232a9606e56f946bc0678a 666018ffec65c5c7e04796081295c6c7 6e69920fa6eef8522a1d688a11e41bc6 eb960de68f0c0f7f9fa083e9f79d0360 8aa12ce243210128c5074552d3b86251 240d4c5ddd4b54069bdc4a3cd2faf99d 1c6cd089e6c83da618fbf2a081eb4888 463d87789c555a4a7604e97d7db545d1 35461cecaa51712b300b2d6798825048 bd6415094e1ce9e05daabe85de807666 2e70ad008d4ec8549aada8002fdf42fb b53d51edc7fc086685e31b811dc32aad 1b6e631b536247756287b916f9396872 00da1b177096cfd2532c8fa22b43e667 afde410bd026c16be605a1ae4bd651fd 81f4336c1de607dd0865011c0447052e 0eee5d1c779aa50e94edd168b4ebf42e d333558cc14561c1fdc334c75d5f37b7 dc752f160044f2ed5fc1f4964db2a095 63ead1d74893bf7f36880af81f68a82d 3e3e030c0f600442fa05b94f87a1e238 1ad977bb539fc9448a08ab276a836bbc eb4f40fcf4911ede39c1bbfe91e7a89a 9959ad7a8685cad66206e7752ca23f8b 929a14baca1776b00869f983aa6e14d2 573f7d4a430c32b3cc0fd0c41e104bbd df63a604e8bff5b0599bd1a6c2721bd0 5b1ba4bb914406fae75ab8e38901684d cb801b7920a7d536ba07b6534d2433ca af60e6d1a939019d55e5b330d24b1c25 549a66d0c698635ca9fa3ab012da7129 5de9d0d730ff1e7ad122806335332524 21fe4cad111f7dc0f9af29477057f88d 40c11c063b3b9409aa5e4058e984e30c 80bbb237a6af9c611df43b16b930b683 c37bce95d32b2be480f87dd32704e664 80ac46fa7e77b8ab4366e86948e54f83 21038400dc633070a78ad53090c53017 dc69f0643a3030aaa4797501b483d6c4 30d56e79d89fbddf10938fa67fe3f34e 93ea3bcee4252627919175ff1b16a1d9 d3e81e95db25f5a86a7b7474550a2155)
			for i in "${PS2Bios[@]}"
			do
				if [[ "$md5" == *"${i}"* ]]; then
					PS2BIOS=true
					break
				else
					PS2BIOS=false
				fi
			done	
		fi
	fi
done

if [ $PSXBIOS == false ]; then
	#text="`printf "<b>PS1 bios not detected</b>\nYou need to copy your BIOS to: ${biosPath}"`"
	text="`printf "<b>PS1 bios not detected</b>\nYou need to copy your BIOS to: \n${biosPath}\n\n<b>Make sure they are not in a subdirectory</b>"`"
	zenity --error \
			--title="EmuDeck" \
			--width=400 \
			--text="${text}" &>> /dev/null
fi

if [ $PS2BIOS == false ]; then
	#text="`printf "<b>PS1 bios not detected</b>\nYou need to copy your BIOS to: ${biosPath}"`"
	text="`printf "<b>PS2 bios not detected</b>\nYou need to copy your BIOS to: \n${biosPath}\n\n<b>Make sure they are not in a subdirectory</b>"`"
	zenity --error \
			--title="EmuDeck" \
			--width=400 \
			--text="${text}" &>> /dev/null
fi


#Yuzu Keys & Firmware
FILE=~/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/prod.keys
if [ -f "$FILE" ]; then
	echo -e "" &>> /dev/null
else
		
	text="`printf "<b>Yuzu is not configured</b>\nYou need to copy your Keys and firmware to: \n${biosPath}yuzu/keys\n${biosPath}yuzu/firmware\n\nMake sure to copy your files inside the folders. <b>Do not overwrite them</b>"`"
	zenity --error \
			--title="EmuDeck" \
			--width=400 \
			--text="${text}" &>> /dev/null
fi

#melonDS permissions?
#flatpak override net.kuribo64.melonDS --filesystem=host --user	

##
##
## RetroArch Customizations.
##
##

#RA SNES Aspect Ratio
if [ $SNESAR == 43 ]; then	
	cp ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes43.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg	
else
	cp ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes87.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg	
fi

#RA Bezels	
if [ $RABezels == true ]; then	
	find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.bak" | while read f; do mv -v "$f" "${f%.*}.cfg"; done &>> ~/emudeck/emudeck.log
else
	find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" | while read f; do mv -v "$f" "${f%.*}.bak"; done &>> ~/emudeck/emudeck.log
fi

#RA AutoSave	
if [ $RAautoSave == true ]; then
	sed -i 's|savestate_auto_load = "false"|savestate_auto_load = "true"|g' $raConfigFile &>> ~/emudeck/emudeck.log
	sed -i 's|savestate_auto_save = "false"|savestate_auto_save = "true"|g' $raConfigFile &>> ~/emudeck/emudeck.log
else
	sed -i 's|savestate_auto_load = "true"|savestate_auto_load = "false"|g' $raConfigFile &>> ~/emudeck/emudeck.log
	sed -i 's|savestate_auto_save = "true"|savestate_auto_save = "false"|g' $raConfigFile &>> ~/emudeck/emudeck.log
fi

#Widescreen hacks
if [ $duckWide == true ]; then	
	sed -i "s|WidescreenHack = false|WidescreenHack = true|g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini &>> ~/emudeck/emudeck.log
else
	sed -i "s|WidescreenHack = true|WidescreenHack = false|g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini &>> ~/emudeck/emudeck.log
fi
if [ $DolphinWide == true ]; then
	sed -i "s|wideScreenHack = False|wideScreenHack = True|g" ~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini &>> ~/emudeck/emudeck.log
else
	sed -i "s|wideScreenHack = True|wideScreenHack = False|g" ~/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini &>> ~/emudeck/emudeck.log
fi
if [ $DreamcastWide == true ]; then
	sed -i "s|reicast_widescreen_hack = \"disabled\"|reicast_widescreen_hack = \"enabled\"|g" ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Flycast/Flycast.opt &>> ~/emudeck/emudeck.log
else
	sed -i "s|reicast_widescreen_hack = \"enabled\"|reicast_widescreen_hack = \"disabled\"|g" ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Flycast/Flycast.opt &>> ~/emudeck/emudeck.log
fi

if [ $BeetleWide == true ]; then
	sed -i "s|beetle_psx_hw_widescreen_hack = \"disabled\"|beetle_psx_hw_widescreen_hack = \"enabled\"|g" "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/Beetle PSX HW/Beetle PSX HW.opt" &>> ~/emudeck/emudeck.log
else
	sed -i "s|beetle_psx_hw_widescreen_hack = \"enabled\"|beetle_psx_hw_widescreen_hack = \"disabled\"|g" "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/Beetle PSX HW/Beetle PSX HW.opt" &>> ~/emudeck/emudeck.log
fi

#We move all the saved folders to the emulation path

#RA
if [ ! -d "$savesPath/retroarch/states" ]; then		
	mkdir -p $savesPath/retroarch
	echo -e ""
	echo -e "Linking RetroArch saved states to the Emulation/saves folder"			
	echo -e ""	
	mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch/states 
	ln -sn ~/.var/app/org.libretro.RetroArch/config/retroarch/states $savesPath/retroarch/states 
fi
if [ ! -d "$savesPath/retroarch/saves" ]; then	
	mkdir -p $savesPath/retroarch
	echo -e ""
	echo -e "Linking RetroArch saved games to the Emulation/saves folder"			
	echo -e ""
	mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch/saves 
	ln -sn ~/.var/app/org.libretro.RetroArch/config/retroarch/saves $savesPath/retroarch/saves 		
fi

#Dolphin
if [ ! -d "$savesPath/dolphin/GC" ]; then	
	mkdir -p $savesPath/dolphin	
	echo -e ""
	echo -e "Linking Dolphin Gamecube saved games to the Emulation/saves folder"			
	echo -e ""	
	mkdir -p ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC
	ln -sn ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC $savesPath/dolphin/GC 
fi
if [ ! -d "$savesPath/dolphin/Wii" ]; then	
	mkdir -p $savesPath/dolphin	
	echo -e ""
	echo -e "Linking Dolphin Wii saved games to the Emulation/saves folder"			
	echo -e ""
	mkdir -p ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii	
	ln -sn ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii $savesPath/dolphin/Wii 
fi
if [ ! -d "$savesPath/dolphin/states" ]; then	
	mkdir -p $savesPath/dolphin	
	echo -e ""
	echo -e "Linking Dolphin States to the Emulation/saves folder"			
	echo -e ""
	mkdir -p ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves
	ln -sn ~/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves $savesPath/dolphin/states
fi

#PrimeHack
if [ ! -d "$savesPath/primehack/GC" ]; then	
	mkdir -p $savesPath/primehack	
	echo -e ""
	echo -e "Linking PrimeHack Gamecube saved games to the Emulation/saves folder"			
	echo -e ""
	mkdir -p ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC
	ln -sn ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC $savesPath/primehack/GC
fi
if [ ! -d "$savesPath/primehack/Wii" ]; then	
	mkdir -p $savesPath/primehack	
	echo -e ""
	echo -e "Linking PrimeHack Wii saved games to the Emulation/saves folder"			
	echo -e ""
	mkdir -p ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii
	ln -sn ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii $savesPath/primehack/Wii	
fi
if [ ! -d "$savesPath/primehack/states" ]; then	
	mkdir -p $savesPath/primehack	
	echo -e ""
	echo -e "Linking PrimeHack States to the Emulation/states folder"			
	echo -e ""
	mkdir -p ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/StateSaves
	ln -sn ~/.var/app/io.github.shiiion.primehack/data/dolphin-emu/StateSaves $savesPath/primehack/states
fi

#Yuzu
if [ ! -d "$savesPath/yuzu/saves" ]; then		
	mkdir -p $savesPath/yuzu
	echo -e ""
	echo -e "Linking Yuzu Saves to the Emulation/saves folder"			
	echo -e ""
	
	mkdir -p ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/sdmc
	ln -sn ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/sdmc $savesPath/yuzu/saves	
fi

#Duckstation
if [ ! -d "$savesPath/duckstation/saves" ]; then		
	mkdir -p $savesPath/duckstation
	echo -e ""
	echo -e "Linking Duckstation Saves to the Emulation/saves folder"			
	echo -e ""
	mkdir -p ~/.var/app/org.duckstation.DuckStation/data/duckstation/memcards
	ln -sn ~/.var/app/org.duckstation.DuckStation/data/duckstation/memcards $savesPath/duckstation/saves	
fi
if [ ! -d "$savesPath/duckstation/states" ]; then	
	mkdir -p $savesPath/duckstation	
	echo -e ""
	echo -e "Linking Duckstation Saves to the Emulation/states folder"			
	echo -e ""
	mkdir -p ~/.var/app/org.duckstation.DuckStation/data/duckstation/savestates
	ln -sn ~/.var/app/org.duckstation.DuckStation/data/duckstation/savestates $savesPath/duckstation/states
fi

#Xemu
if [ ! -d "$savesPath/xemu" ]; then		
	mkdir -p "$savesPath/xemu"
	echo -e ""
	echo -e "Moving Xemu HDD and EEPROM to the Emulation/saves folder"			
	echo -e ""
	mv /home/deck/.var/app/app.xemu.xemu/data/xemu/xemu/xbox_hdd.qcow2 $savesPath/xemu 
	mv /home/deck/.var/app/app.xemu.xemu/data/xemu/xemu/eeprom.bin $savesPath/xemu 	
fi

#PCSX2
if [ ! -d "$savesPath/pcsx2/saves" ]; then		
	mkdir -p $savesPath/pcsx2
	echo -e ""
	echo -e "Linking PCSX2 Saves to the Emulation/saves folder"			
	echo -e ""	
	mkdir -p ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards
	ln -sn ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards $savesPath/pcsx2/saves
fi
if [ ! -d "$savesPath/pcsx2/states" ]; then	
	mkdir -p $savesPath/pcsx2	
	echo -e ""
	echo -e "Linking PCSX2 Saves to the Emulation/states folder"			
	echo -e ""	
	mkdir -p ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates
	ln -sn ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates $savesPath/pcsx2/states
fi

#RPCS3
if [ ! -d "$savesPath/rpcs3/dev_hdd0/savedata" ]; then		
	echo -e ""
	echo -e "Moving rpcs3 hdd0 to the Emulation/Saves folder"			
	echo -e "Depending on how many pkgs you have installed, this may take a while."
	if [ $destination == "SD" ]; then
		echo -e "If you don't have enough available space in your SD Card this will fail, clean up your SD Card and run EmuDeck Again."
	fi
	mkdir -p "$savesPath/rpcs3" >> ~/emudeck/emudeck.log
	rsync -r ~/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0 "$savesPath"/rpcs3/ && rm -rf ~/.var/app/net.rpcs3.RPCS3/config/rpcs3/dev_hdd0 >> ~/emudeck/emudeck.log
	#update config file for the new loc $(emulatorDir) is in the file. made this annoying.
	sed -i "'s|$(EmulatorDir)dev_hdd0/|'$savesPath'/rpcs3/dev_hdd0/|g'" /home/deck/.var/app/net.rpcs3.RPCS3/config/rpcs3/vfs.yml >> ~/emudeck/emudeck.log
fi

#Citra
if [ ! -d "$savesPath/citra/saves" ]; then		
	mkdir -p $savesPath/citra
	echo -e ""
	echo -e "Linking Citra Saves to the Emulation/saves folder"			
	echo -e ""	
	mkdir -p ~/.var/app/org.citra_emu.citra/data/citra-emu/sdmc
	ln -sn ~/.var/app/org.citra_emu.citra/data/citra-emu/sdmc $savesPath/citra/saves
fi
if [ ! -d "$savesPath/citra/states" ]; then	
	mkdir -p $savesPath/citra	
	echo -e ""
	echo -e "Linking Citra Saves to the Emulation/states folder"			
	echo -e ""
	mkdir -p ~/.var/app/org.citra_emu.citra/data/citra-emu/states
	ln -sn ~/.var/app/org.citra_emu.citra/data/citra-emu/states $savesPath/citra/states
fi
#PPSSPP
if [ ! -d "$savesPath/ppsspp/saves" ]; then		
	mkdir -p $savesPath/ppsspp
	echo -e ""
	echo -e "Linking PPSSPP Saves to the Emulation/saves folder"			
	echo -e ""
	mkdir -p ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA
	ln -sn ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA $savesPath/ppsspp/saves
fi
if [ ! -d "$savesPath/ppsspp/states" ]; then	
	mkdir -p $savesPath/ppsspp	
	echo -e ""
	echo -e "Linking PPSSPP Saves to the Emulation/states folder"			
	echo -e ""
	mkdir -p ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE
	ln -sn ~/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE $savesPath/ppsspp/states	
fi

#RetroAchievments
#Disabled until we know why in the world the deck's screen keyword can't type in a zenity dialog
if [ -f ~/emudeck/.rap ]; then 
	rap=$(cat ~/emudeck/.rap)
	rau=$(cat ~/emudeck/.rau)

	sed -i "s|cheevos_password = \"\"|cheevos_password = \"${rap}\"|g" $raConfigFile	
	sed -i "s|cheevos_username = \"\"|cheevos_username = \"${rau}\"|g" $raConfigFile	
	sed -i "s|cheevos_enable = \"false\"|cheevos_enable = \"true\"|g" $raConfigFile
	

else

	text="`printf "Do you want to use RetroAchievments on Retroarch?\n\n<b>You need to have an account on https://retroachievements.org</b>\n\n Activating RetroAchievments will disable save states unless you disable hardcore mode "`"
	zenity --question \
			 --title="EmuDeck" \
			 --width=450 \
			 --ok-label="Yes" \
			 --cancel-label="No" \
			 --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		text="`printf "What is your RetroAchievments username?\n\nPress STEAM + X to get the onscreen Keyboard"`"
		username=$(zenity --entry \
						--title="EmuDeck" \
						--width=450 \
						--ok-label="OK" \
						--cancel-label="Cancel" \
						--text="${text}")
		ans=$?
		if [ $ans -eq 0 ]
		then
			echo "${username}" > ~/emudeck/.rau
			text="`printf "What is your RetroAchievments password?\n\nPress STEAM + X to get the onscreen Keyboard"`"
			password=$(zenity --password \
							  --title="EmuDeck" \
							  --width=450 \
							  --ok-label="OK" \
							  --cancel-label="Cancel" \
							  --text="${text}")							  
			ans=$?
			if [ $ans -eq 0 ]
			then
				echo "${password}" > ~/emudeck/.rap
			else
				echo "Cancel RetroAchievment Password" &>> /dev/null
			fi
		else
			echo "Cancel RetroAchievment User" &>> /dev/null
		fi
		
		rap=$(cat ~/emudeck/.rap)
		rau=$(cat ~/emudeck/.rau)
		
		sed -i "s|cheevos_password = \"\"|cheevos_password = \"${rap}\"|g" $raConfigFile	
		sed -i "s|cheevos_username = \"\"|cheevos_username = \"${rau}\"|g" $raConfigFile	
		sed -i "s|cheevos_enable = \"false\"|cheevos_enable = \"true\"|g" $raConfigFile
		
	else
		echo "" &>> /dev/null		
	
	fi

fi

if [ $doInstallCHD == true ]; then
	mkdir -p  "$toolsPath"chdconv/
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/tools/chdconv/ "$toolsPath"chdconv/ &>> ~/emudeck/emudeck.log
	
	rm -rf ~/Desktop/EmuDeckCHD.desktop &>> /dev/null
	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=EmuDeck CHD Script
	Exec=bash "$toolsPath"chdconv/chddeck.sh
	Icon=steamdeck-gaming-return
	Terminal=true
	Type=Application
	StartupNotify=false" > ~/Desktop/EmuDeckCHD.desktop
	chmod +x ~/Desktop/EmuDeckCHD.desktop	
	chmod +x "$toolsPath"chdconv/chddeck.sh
	chmod +x "$toolsPath"chdconv/chdman5
	#update the paths in the script
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" "$toolsPath"chdconv/chddeck.sh
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" "$toolsPath"chdconv/chddeck.sh

fi

if [ $doInstallPowertools == true ]; then
	
	hasPass=$(grep -rn '/etc/passwd' -e "$(whoami):") #makes it work for the current user.
	
	if [[ $hasPass == '' ]]; then
		text="`printf "In order to install PowerTools you need to set a password for the deck user.\n\n Remember this password. If you forget it you will need to format your Deck to change it\n\n<b>When you type your password, it will not appear on screen, this is normal</b>"`"
		zenity --question \
				 --title="EmuDeck" \
				 --width=250 \
				 --ok-label="Continue" \
				 --cancel-label="Cancel" \
				 --text="${text}" &>> /dev/null
		ans=$?
		if [ $ans -eq 0 ]; then
			passwd
			continuePowerTools=true
		else
			echo "No passwd creation" >> ~/emudeck/emudeck.log
			continuePowerTools=false
		fi
	else
		continuePowerTools=true
		echo "User already has passwd" >> ~/emudeck/emudeck.log
	fi
	
	if [ $continuePowerTools == true ]; then
		echo "Installing ${BOLD} Plugin loader. Insert your password when required  ${NONE}"
		curl -L https://github.com/SteamDeckHomebrew/PluginLoader/raw/main/dist/install_release.sh | sh	>> ~/emudeck/emudeck.log
		sudo rm -rf ~/homebrew/plugins/PowerTools
		sudo git clone https://github.com/NGnius/PowerTools.git ~/homebrew/plugins/PowerTools >> ~/emudeck/emudeck.log
		sleep 1
		cd ~/homebrew/plugins/PowerTools
		sudo git checkout tags/v0.3.0 >> ~/emudeck/emudeck.log
		text="$(printf "To finish the installation go into the Steam UI Settings\n\n
		Under System -> System Settings toggle Enable Developer Mode\n\n
		Scroll the sidebar all the way down and click on Developer\n\n
		Under Miscellaneous, enable CEF Remote Debugging\n\n
		In order to improve performance on Yuzu or Dolphin try configuring Powertools to activate only 4 CPU Cores\n\n
		You can Access Powertools by presing the ... button and selecting the new Plugins Menu\n\n
		\n\n
		IMPORTANT - The Powertools menu is touch ONLY.\n\n")"
		zenity --info \
		   --title="EmuDeck" \
		   --width=450 \
		   --text="${text}"
	fi

fi

# We mark the script as finished	
echo "" > ~/emudeck/.finished

if [ $branch == 'main' ];then

	#We create new icons
	rm -rf ~/Desktop/EmuDeckUninstall.desktop &>> /dev/null
	echo '#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=Uninstall EmuDeck
	Exec=curl https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/uninstall.sh | bash -s -- SD
	Icon=delete
	Terminal=true
	Type=Application
	StartupNotify=false' > ~/Desktop/EmuDeckUninstall.desktop
	chmod +x ~/Desktop/EmuDeckUninstall.desktop
	
	rm -rf ~/Desktop/EmuDeck.desktop &>> /dev/null
	rm -rf ~/Desktop/EmuDeckSD.desktop &>> /dev/null
	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=EmuDeck (${version})
	Exec=curl https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash -s -- SD
	Icon=steamdeck-gaming-return
	Terminal=true
	Type=Application
	StartupNotify=false" > ~/Desktop/EmuDeck.desktop
	chmod +x ~/Desktop/EmuDeck.desktop

fi

echo -e "Cleaning up downloaded files..."	
rm -rf ~/dragoonDoriseTools	
clear

text="`printf "<b>Done!</b>\n\nRemember to add your games here:\n<b>${romsPath}</b>\nAnd your Bios (PS1, PS2, Yuzu) here:\n<b>${biosPath}</b>\n\nOpen Steam Rom Manager to add your games to your SteamUI Interface.\n\n<b>Remember that Cemu games needs to be set in compatibility mode in SteamUI: Proton 7 by going into its Properties and then Compatibility</b>\n\nThere is a bug in RetroArch that if you are using Bezels you can not set save configuration files unless you close your current game. Use overrides for your custom configurations or use expert mode to disabled them\n\nIf you encounter any problem please visit our Discord:\n<b>https://discord.gg/b9F7GpXtFP</b>\n\nTo Update EmuDeck in the future, just run this App again.\n\nEnjoy!"`"

zenity --question \
		 --title="EmuDeck" \
		 --width=450 \
		 --ok-label="Open Steam Rom Manager" \
		 --cancel-label="Exit" \
		 --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	cd ~/Desktop/
	./Steam-ROM-Manager.AppImage
	exit
else
	echo -e "Exit" &>> /dev/null
fi
