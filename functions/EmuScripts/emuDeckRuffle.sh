#!/bin/bash

#variables
Ruffle_emuName="Ruffle"
Ruffle_emuType="Binary"
Ruffle_emuPath="$HOME/Applications/ruffle"
Ruffle_file_name="ruffle-nightly-$(date +'%Y-%m-%d')-linux-x86_64.tar.gz"

#Install
Ruffle_install(){
    echo "Begin Ruffle Install"
    local showProgress="$1"

    if installEmuBI "Ruffle" "https://github.com/ruffle-rs/ruffle/releases/download/nightly-$(date +'%Y-%m-%d')/$Ruffle_file_name" "Ruffle" "tar.gz" "$showProgress"; then
        mkdir "$HOME/$Ruffle_emuPath"
		tar -zxvf "$HOME/Applications/$Ruffle_file_name" -C "$HOME/Applications/ruffle" ruffle && rm -rf "$HOME/Applications/$Ruffle_file_name"
        chmod +x "$Ruffle_emuPath/ruffle"

    else
        return 1
    fi
}

#Uninstall
Ruffle_uninstall(){
    echo "Begin Ruffle uninstall"
    rm -rf "$HOME/Applications/ruffle" #Full path. Let's avoid a empty location while rm -rf
}

Ruffle_IsInstalled(){
    if [ -e "$Ruffle_emuPath/ruffle" ]; then
        echo "true"
    else
        echo "false"
    fi
}