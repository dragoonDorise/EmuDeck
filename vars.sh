#!/usr/bin/env bash
emudeckFolder="$HOME/.config/EmuDeck"
emudeckLogs="$HOME/.config/EmuDeck/logs"
appFolder="$HOME/Applications"
emusFolder="$appFolder"
esdeFolder="$appFolder"
pegasusFolder="$appFolder"
pythonBackend="$emudeckBackend/python"
pyVenv="$emudeckFolder/python_virtual_env"
CPUarch="x86"
if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then
	CPUarch="arm"
fi