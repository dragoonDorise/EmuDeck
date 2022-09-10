#!/bin/bash

RemoteWhatever_install(){		
	mkdir -p "${toolsPath}/remoteplaywhatever"
	installEmuAI "RemotePlayWhatever"  "$(getReleaseURLGH "m4dEngi/RemotePlayWhatever" "AppImage")" 
	RemoteWhatever_init
}

RemoteWhatever_init(){			
	setMSG "Configuring RemotePlayWhatever"
	cp "$EMUDECKGIT/tools/remoteplaywhatever/remoteplaywhatever.sh" "${toolsPath}/remoteplaywhatever/"
	chmod +x "${toolsPath}/remoteplaywhatever/remoteplaywhatever.sh"
	echo -e "OK!"
}
