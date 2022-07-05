#!/bin/bash
installEmuFP() {
	name=$1
	ID=$2

	setMSG "Installing $name"

	flatpak install flathub $ID -y --system
	flatpak override $ID --filesystem=host --user
	flatpak override $ID --share=network --user

	shName=$(echo "$name" | awk '{print tolower($0)}')

	find "${toolsPath}"launchers/ -type f -iname $shName.sh | while read f; do
		echo "deleting $f"
		rm -f "$f"
	done
	cp "${EMUDECKGIT}"/tools/launchers/"${shName}".sh "${toolsPath}"launchers/"${shName}".sh
	chmod +x "${toolsPath}"launchers/"${shName}".sh
}
