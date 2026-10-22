#!/bin/bash

emuDeckInstallHomebrewGame(){ py_run --print store_install_game "$@"; }
emuDeckUnInstallHomebrewGame(){ py_run --print store_uninstall_game "$@"; }
