#!/bin/bash

#
##
### Darwin overrides
##
#


API_pull(){
	local branch=$1
	cd ~/.config/EmuDeck/backend && git reset --hard && git clean -fd && git checkout ${branchGIT} && git pull && . ~/.config/EmuDeck/backend/functions/all.sh && appImageInit
}
