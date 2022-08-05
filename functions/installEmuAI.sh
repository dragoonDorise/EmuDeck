#!/bin/bash
installEmuAI(){		
	
	name=$1
	url=$2	
    altName=$3

    if [[ $altName == "" ]]; then
        altName=$name
    fi
	echo $name
    echo $url
    echo $altName

    rm -f "$HOME/Applications/$altName.AppImage" 
    mkdir -p "$HOME/Applications"
    curl -L "$url" -o "$HOME/Applications/$altName.AppImage" 
	chmod +x "$HOME/Applications/$altName.AppImage" 


    shName=$(echo "$name" | awk '{print tolower($0)}')
    find "${toolsPath}/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
    while read -r f
    do 
        echo "deleting $f"
        rm -f "$f"
    done

    find "${EMUDECKGIT}/tools/launchers/" -type f -iname "$shName.sh" -o -type f -iname "$shName-emu.sh" | \
    while read -r l
    do 
        echo "deploying $l"
        launcherFileName=$(basename "$l")
        chmod +x "$l"
        cp -v "$l" "${toolsPath}/launchers/"
        chmod +x "${toolsPath}/launchers/"*

        createDesktopShortcut   "$HOME/.local/share/applications/$altName.desktop" \
                                "$altName EmuDeck" \
                                "${toolsPath}/launchers/$launcherFileName" \
                                "false"
    done

 
                            
}
