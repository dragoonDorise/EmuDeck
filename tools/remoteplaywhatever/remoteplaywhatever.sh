#!/bin/bash

	 text="`printf " <b>Multiplayer Instructions</b>\n\n Invite your friend on the next window\n\nPress the STEAM Button and go back to Library, open <b>EmulationStation</b>, launch your game and enjoy!!\n\nAs of now only games launched using EmulationStation work on Multiplayer mode\n\n<b>RemotePlayWhatever is in early beta, so expecto some crashes here and there</b>)"`"
 zenity --info \
		 --title="EmuDeck" \
		 --width="450" \
		 --text="${text}" 2>/dev/null	

~/Applications/RemotePlayWhatever.AppImage

