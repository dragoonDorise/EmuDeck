#!/bin/bash

RemotePlayWhatever_install(){		
	mkdir -p "${toolsPath}/remoteplaywhatever"
	installEmuAI "RemotePlayWhatever"  "$(getReleaseURLGH "m4dEngi/RemotePlayWhatever" "AppImage")" 
	RemotePlayWhatever_init
}

RemotePlayWhatever_init(){			
	setMSG "Configuring RemotePlayWhatever"
	cp "$EMUDECKGIT/tools/remoteplaywhatever/remoteplaywhatever.sh" "${toolsPath}/remoteplaywhatever/"
	chmod +x "${toolsPath}/remoteplaywhatever/remoteplaywhatever.sh"
	echo -e "OK!"
	 zenity --question --width 450 --title "Close Steam/Steam Input?" --text "Now we will exit steam and launch Steam ROM Manager so you can add RemotePlayWhatever. Desktop controls will temporarily revert to touch/trackpad/L2/R2 until you open Steam again." && (kill -15 $(pidof steam)) & cp $HOME/.config/EmuDeck/backend/configs/steam-rom-manager/userData/userConfigurationsRPW.json $HOME/.config/steam-rom-manager/userData/userConfigurations.json && ${toolsPath}/Steam ROM Manager.AppImage && cp $HOME/.config/EmuDeck/backend/configs/steam-rom-manager/userData/userConfigurations.json $HOME/.config/steam-rom-manager/userData/userConfigurations.json

}
