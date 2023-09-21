#!/bin/bash

if ! command -v brew &> /dev/null; then
  hasBrew=false
else
  hasBrew=true
fi

function prompt() {
  osascript <<EOT
	tell app "System Events"
	  text returned of (display dialog "$1" default answer "$2" buttons {"OK"} default button 1 with title "Flying Pigs - Mac Setup")
	end tell
EOT
}

if [ hasBrew == "false" ]; then
	pass="$(prompt 'EmuDeck needs to install Brew, and for that you need to input your password:' '')"
	echo $pass | sudo -v -S && {
		/bin/bash -c "$(curl -fsSLk https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	}	
fi

#Brew dependencies
echo "Installing EmuDeck dependencies..."
brew install zenity gnu-sed -y



echo "All prerequisite packages have been installed. EmuDeck will be installed now!"


