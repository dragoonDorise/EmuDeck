#!/bin/bash
#We need this function to launch SRM from the electron app
runSRM(){	
	local path=$1
	cd $path && ./Steam-ROM-Manager.AppImage
}