#!/bin/bash
clear
appleChip=$(uname -m)

function getLatestReleaseURLGH(){
	local repository=$1
	local fileType=$2
	local fileNameContains=$3
	local url
	#local token=$(tokenGenerator)

	if [ "$url" == "" ]; then
		url="https://api.github.com/repos/${repository}/releases/latest"
	fi

	curl -fSs "$url" | \
		jq -r '[ .assets[] | select(.name | contains("'"$fileNameContains"'") and endswith("'"$fileType"'")).browser_download_url ][0] // empty'
}

function alert() {
  osascript <<EOT
	tell app "System Events"
	  display dialog "$1" buttons {"OK"} default button 1 with icon caution with title "Flying Pigs - Mac Setup"
	  return  -- Suppress result
	end tell
EOT
}

safeDownload() {
	local name="$1"
	local url="$2"
	local outFile="$3"
	local showProgress="$4"
	local headers="$5"
	if [ "$showProgress" == "true" ]; then
		echo "safeDownload()"
		echo "- $name"
		echo "- $url"
		echo "- $outFile"
		echo "- $showProgress"
		echo "- $headers"
	fi

	request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 && echo $'\2'0 || echo $'\2'$?)

	returnCodes="${request#*$'\1'}"
	httpCode="${returnCodes%$'\2'*}"
	exitCode="${returnCodes#*$'\2'}"

	if [ "$httpCode" = "200" ] && [ "$exitCode" == "0" ]; then
		#echo "$name downloaded successfully";
		mv -v "$outFile.temp" "$outFile" &>/dev/null
		volumeName=$(yes | hdiutil attach "$outFile" | grep -o '/Volumes/.*$')
		return 0
	else
		#echo "$name download failed"
		rm -f "$outFile.temp"
		return 1
	fi

}

if ! command -v brew &> /dev/null; then
  hasBrew=false
else
  hasBrew=true
fi

function prompt() {
  osascript <<EOT
	tell app "System Events"
	  text returned of (display dialog "$1" default answer "$2" buttons {"OK"} default button 1 with title "EmuDeck - Mac Dependencies")
	end tell
EOT
}

if [ $hasBrew == "false" ]; then
	pass="$(prompt 'EmuDeck needs to install Brew, and for that you need to input your password:' '')"
	echo $pass | sudo -v -S && {
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSLk https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	}

	if [ $appleChip == "arm64" ];then
		echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.bash_profile && source ~/.bash_profile
		echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.zshrc && source ~/.zshrc
	else
		echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile && source ~/.bash_profile
		echo "export PATH=/usr/local/bin:$PATH" >> ~/.zshrc && source ~/.zshrc
	fi

fi

#Brew dependencies
alert "Let's install EmuDeck dependencies... This could take some time. Please press OK"
brew install zenity gnu-sed rsync xmlstarlet jq steam
if ! command -v xcode-select &>/dev/null; then
	xcode-select --install
	wait
fi


alert "All prerequisite packages have been installed. EmuDeck's DMG will be installed now!. Please press OK"

if [ $appleChip == "arm64" ];then
	EmuDeckURL="$(getLatestReleaseURLGH "EmuDeck/emudeck-electron-early" "arm64.dmg")"
else
	EmuDeckURL="$(getLatestReleaseURLGH "EmuDeck/emudeck-electron-early" ".dmg")"
fi

safeDownload "EmuDeck" "$EmuDeckURL" "$HOME/Downloads/EmuDeck.dmg" && open "$HOME/Downloads/EmuDeck.dmg"

exit
