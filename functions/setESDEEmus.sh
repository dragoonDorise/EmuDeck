#!/bin/bash
setESDEEmus(){		
	emu=$1
	system=$2
	FILE=~/.emulationstation/gamelists/$system/gamelist.xml
	if [ ! -f "$FILE" ]; then
		mkdir -p ~/.emulationstation/gamelists/$system && cp $EMUDECKGIT/configs/emulationstation/gamelists/$system/gamelist.xml $FILE
	else
		gamelistFound=$(grep -rnw $FILE -e 'gameList')
		if [[ $gamelistFound == '' ]]; then
			sed -i -e '$a\<gameList />' $FILE
		fi
		alternativeEmu=$(grep -rnw $FILE -e 'alternativeEmulator')
		if [[ $alternativeEmu == '' ]]; then
			echo "<alternativeEmulator><label>$emu</label></alternativeEmulator>" >> $FILE
		fi
		sed -i "s|<?xml version=\"1.0\">|<?xml version=\"1.0\"?>|g" $FILE
	fi
}