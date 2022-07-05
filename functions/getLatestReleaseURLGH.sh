#!/bin/bash

getLatestReleaseURLGH() {
	repository=$1
	fileType=$2

	url="$(curl -sL https://api.github.com/repos/${repository}/releases/latest | jq -r ".assets[].browser_download_url" | grep .${fileType}\$)"

	echo "$url"
}
