#!/bin/bash
installEmuAI(){		
	
	name=$1
	url=$2	
	
    mkdir -p $HOME/Applications
    cd $HOME/Applications

    wget $url
	
    shName=$(echo "$name" | awk '{print tolower($0)}')
    
	cp "${EMUDECKGIT}"/tools/launchers/"${shName}".sh "${toolsPath}"launchers/"${shName}".sh	
	
}