#!/bin/bash
installEmuAI(){		
	
	name=$1
	url=$2	
    altName=$3

    if [[ $altName == "" ]]; then
        altName=$name
    fi
	
    mkdir -p $HOME/Applications
    cd $HOME/Applications

    wget -c "$url" -O "$altName.AppImage" 
	
    shName=$(echo "$name" | awk '{print tolower($0)}')
    
	cp "${EMUDECKGIT}"/tools/launchers/"${shName}".sh "${toolsPath}"launchers/"${shName}".sh	
	

    
}