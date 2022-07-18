#!/bin/bash
installEmuAI(){		
	
	name=$1
	url=$2	
    altName=$3

    if [[ $altName == "" ]]; then
        altName=$name
    fi
	
    mkdir -p "$HOME/Applications"

    curl -Lo "$HOME/Applications/$altName.AppImage" "$url"
    
	chmod +x "$HOME/Applications/$altName.AppImage" 

    curl -Lo "$altName.AppImage" "$url"
	chmod +x "$altName.AppImage"  
    shName=$(echo "$name" | awk '{print tolower($0)}')
    
    find "${toolsPath}launchers/" -type f -iname "$shName.sh" | while read f; do echo "deleting $f"; rm -f "$f"; done;
	cp -v "${EMUDECKGIT}/tools/launchers/${shName}.sh" "${toolsPath}launchers/${shName}.sh"	
	chmod +x "${toolsPath}launchers/${shName}.sh"
    
}
