#!/bin/bash
clear
cd .config/EmuDeck/backend
git pull
cd $HOME
python3 .config/EmuDeck/backend/api.py ra_install