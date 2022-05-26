#!/bin/bash

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

#setMSG "Downloading files from $branch channel..."
#sleep 5
notify-send -t 3000 "Downloading EmuDeck files from ${branch} channel..."

#Clean up from previous installations
rm ~/emudek.log 2>/dev/null # This is emudeck's old log file, it's not a typo!
rm -rf ~/dragoonDoriseTools
mkdir -p ~/emudeck

#We create all the needed folders for installation
mkdir -p dragoonDoriseTools
mkdir -p dragoonDoriseTools/EmuDeck

git clone https://github.com/dragoonDorise/EmuDeck.git ~/dragoonDoriseTools/EmuDeck 
if [ ! -z "$devMode" ]; then
	cd ~/dragoonDoriseTools/EmuDeck
	git checkout $branch 
fi

FOLDER=~/dragoonDoriseTools/EmuDeck
if [ -d "$FOLDER" ]; then
	echo -e "OK!"
else
	echo -e ""
	echo -e "We couldn't download the needed files, exiting in a few seconds"
	echo -e "Please close this window and try again in a few minutes"
	sleep 999999
	exit
fi

cd $FOLDER
sh doInstall.sh $devMode