#!/usr/bin/env bash
Ports_status(){ py_run --print ports_status; }
Ports_install(){ py_run ports_run install_init "$1"; }
Ports_uninstall(){ py_run ports_run uninstall "$1"; }
Ports_launch(){ py_run ports_run launch "$1"; }
