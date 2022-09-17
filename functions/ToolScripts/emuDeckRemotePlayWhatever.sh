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
}
