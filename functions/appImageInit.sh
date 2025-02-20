#!/bin/bash
appImageInit() {

	#Fix cloudsync upload
	if [ -f "$toolsPath/rclone/rclone" ]; then
		if [ ! -f "$HOME/.config/systemd/user/EmuDeckCloudSync.service" ]; then
		zenity --info --text="If you are seeing this pop-up, that means you were affected by the CloudSync not uploading bug. It should be fixed now"
		--title="CloudSync" \
		--width=400 \
		--height=300
			cloud_sync_createService
		fi
	fi

	#Fix branch bugs
	cd "$HOME/.config/EmuDeck/backend"
	branchName=$(git rev-parse --abbrev-ref HEAD)


	if [ ! -f "$HOME/emudeck/.$branchName" ]; then
		if [[ $branchName =~ early ]]; then
			rm -rf "$HOME/.config/EmuDeck/backend"
			mkdir -p "$HOME/.config/EmuDeck/backend"
			cd "$HOME/.config/EmuDeck/backend"
			git clone  --no-single-branch --depth=1 https://github.com/dragoonDorise/EmuDeck.git .
			git checkout $branchName
			touch "$HOME/emudeck/.$branchName"

			zenity --info --text="Branch fixed, please manually restart EmuDeck"
			--title="Restart needed" \
			--width=400 \
			--height=300
		fi
	fi

	# Init functions
	mkdir -p "$HOME/emudeck/logs"
	mkdir -p "$HOME/emudeck/feeds"

}
