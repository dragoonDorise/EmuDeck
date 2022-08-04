#!/bin/bash
installEmuBI(){		
    
    name=$1
    url=$2	
    altName=$3
    format=$4

    if [[ $altName == "" ]]; then
        altName=$name
    fi
    echo $name
    echo $url
    echo $altName

    rm -f "$HOME/Applications/$altName" 
    mkdir -p "$HOME/Applications"
    curl -L "$url" -o "$HOME/Applications/$altName.$format" 
    


    shName=$(echo "$name" | awk '{print tolower($0)}')
    
    find "${toolsPath}/launchers/" -type f -iname "$shName.sh" | while read -r f; do echo "deleting $f"; rm -f "$f"; done;
    cp -v "${EMUDECKGIT}/tools/launchers/${shName}.sh" "${toolsPath}/launchers/${shName}.sh"	
    chmod +x "${toolsPath}/launchers/${shName}.sh"

    createDesktopShortcut   "$HOME/.local/share/applications/$altName.desktop" \
                            "$altName EmuDeck" \
                            "${toolsPath}/launchers/${shName}.sh" \
                            "false"
                                                        
}