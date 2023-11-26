#!/bin/bash
installEmuAI(){
	local name="$1"
	local url="$2"
	local fileName="$3"

	darwin_installEmuDMG "$name" "$url" "$fileName"

}
