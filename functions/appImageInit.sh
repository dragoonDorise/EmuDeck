#!/bin/bash
appImageInit() {
	if ! declare -p cloud_sync_status &>/dev/null && [ -f "$cloud_sync_bin" ]; then
		setSetting cloud_sync_status true
	fi
}
