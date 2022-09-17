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
	# zenity --question --width 450 --title \"Close Steam/Steam Input?\" --text \"Now we will exit steam and launch Steam Rom Manager so you can add RemotePlayWhatever. Desktop controls will temporarily revert to touch/trackpad/L2/R2. Closing Steam Rom Manager will open Steam back again.\" && (kill -15 \$(pidof steam) && cp $HOME/emudeck/backend/configs/steam-rom-manager/userData/userConfigurationsRPW.json $HOME/.config/steam-rom-manager/userData/userConfigurations.json & /run/media/mmcblk0p1/Emulation/tools/srm/Steam-ROM-Manager.AppImage && cp $HOME/emudeck/backend/configs/steam-rom-manager/userData/userConfigurations.json $HOME/.config/steam-rom-manager/userData/userConfigurations.json & /usr/bin/steam %U -silent & exit)

}
