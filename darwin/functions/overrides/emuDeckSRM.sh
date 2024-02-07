#!/bin/bash
SRM_setEnv(){
	whoami=$(whoami)
	sed -i "s|WHOAMI|${whoami}|g" "$SRM_userData_configDir/userSettings.json"	
}
