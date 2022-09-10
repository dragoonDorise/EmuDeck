#!/bin/bash

RemoteWhatever_install(){		
	mkdir -p "${toolsPath}/remotewhatever"
	installEmuAI "RemotePlayWhatever"  "$(getReleaseURLGH "m4dEngi/RemotePlayWhatever" "AppImage")" 
	RemoteWhatever_init
}

RemoteWhatever_init(){			
	setMSG "Configuring RemoteWhatever"
	cp -v "$EMUDECKGIT/tools/remotewhatever/remotewhatever.sh" "${toolsPath}/remotewhatever/"
	chmod +x "${toolsPath}/remotewhatever/remotewhatever.sh"
	echo -e "OK!"
}
