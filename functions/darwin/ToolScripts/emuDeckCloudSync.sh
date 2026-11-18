#!/usr/bin/env bash
cloud_sync_install_and_config(){ py_run cloud_sync_install_and_config "$1" "$2" >/dev/null && echo "true_cs"; }
cloud_sync_toggle(){ py_run cloud_sync_toggle "$1"; }
cloud_sync_downloadEmuAll(){ py_run cloud_sync_download_emu_all; }
cloud_sync_uploadEmuAll(){ py_run cloud_sync_upload_emu_all; }
cloud_sync_uninstall(){ py_run cloud_sync_uninstall; }
