#!/bin/bash
ESDE_SetAppImageURLS() {
	local json="$(curl -s $ESDE_releaseJSON)"
	
	if [ appleChip == 'arm64' ]; then
		ESDE_releaseURL=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "macOSApple") | .url')
	else
		ESDE_releaseURL=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "macOSApple") | .url')
	fi
	# 
	# ESDE_releaseURL=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "LinuxSteamDeckAppImage") | .url')
	# ESDE_releaseMD5=$(echo "$json" | jq -r '.stable.packages[] | select(.name == "LinuxSteamDeckAppImage") | .md5')
	# ESDE_prereleaseURL=$(echo "$json" | jq -r '.prerelease.packages[] | select(.name == "LinuxSteamDeckAppImage") | .url')
	# ESDE_prereleaseMD5=$(echo "$json" | jq -r '.prerelease.packages[] | select(.name == "LinuxSteamDeckAppImage") | .md5')
}