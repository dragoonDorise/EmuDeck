ZSNES_emuName="zsnes"
ZSNES_emuPath="$emusFolder/zsnes/SUPERZSNES"
ZSNES_configPath="${XDG_CONFIG_HOME:-$HOME/.config}/unity3d/ZEMU Software Inc_/SUPERZSNES"
ZSNES_configFile="$ZSNES_configPath/szsnes_ui.data"


# Install
ZSNES_install(){
	setMSG "Downloading $ZSNES_emuName"

	local url_zsnes
	url_zsnes=$(curl -fsSL "https://www.zsnes.com/" | grep -oE 'files/SuperZSNES[^"]*\.tar\.gz' | head -n 1); [ -n "$url_zsnes" ] || return 1

	mkdir -p "$emusFolder/zsnes" || return 1

	if safeDownload "ZSNES" "https://www.zsnes.com/$url_zsnes" "$emusFolder/zsnes/zsnes.tar.gz" "$showProgress"; then
		tar -xzf "$emusFolder/zsnes/zsnes.tar.gz" -C "$emusFolder/zsnes" || return 1
		rm -f "$emusFolder/zsnes/zsnes.tar.gz"
		chmod +x "$ZSNES_emuPath"
	else
		return 1
	fi

	cp "$emudeckBackend/tools/launchers/zsnes.sh" "$toolsPath/launchers/zsnes.sh"
	cp "$emudeckBackend/tools/launchers/zsnes.sh" "$romsPath/emulators/zsnes.sh"

	chmod +x "$toolsPath/launchers/zsnes.sh"
	chmod +x "$romsPath/emulators/zsnes.sh"

	createDesktopShortcut "$HOME/.local/share/applications/zsnes.desktop" "$ZSNES_emuName" "$toolsPath/launchers/zsnes.sh" "False"
}

ZSNES_init(){
	setMSG "ZSNES - Configuration"

	mkdir -p "$ZSNES_configPath"

	rsync -avhp "$emudeckBackend/configs/zsnes/" \
		"$ZSNES_configPath/" --backup --suffix=.bak || return 1

	ZSNES_setupSaves
}

ZSNES_setupSaves(){
	setMSG "ZSNES - Saves"

	mkdir -p "$savesPath/zsnes/saves" "$savesPath/zsnes/states"

	python3 - "$ZSNES_configFile" "$savesPath" <<'PY'
import sys
from pathlib import Path

config = Path(sys.argv[1])
data = config.read_bytes()

for marker, folder in [
    (b"%SAVES_PATH%", "saves"),
    (b"%STATES_PATH%", "states"),
]:
    position = data.find(marker)
    if position == -1:
        continue

    path = f"{sys.argv[2]}/zsnes/{folder}".encode("utf-8")
    length = len(path)
    prefix = bytearray()

    while length >= 128:
        prefix.append((length & 127) | 128)
        length >>= 7
    prefix.append(length)

    data = data[:position - 1] + prefix + path + data[position + len(marker):]

config.write_bytes(data)
PY
}

ZSNES_IsInstalled(){
	if [ -f "$ZSNES_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

ZSNES_uninstall(){
	rm -rf "$emusFolder/zsnes" && echo "true" || echo "false"
}

ZSNES_resetConfig(){
	ZSNES_init &>/dev/null && echo "true" || echo "false"
}

ZSNES_flushEmulatorLauncher(){
	flushEmulatorLaunchers "zsnes"
}

ZSNES_addToSteam(){
	setMSG "Adding $ZSNES_emuName to Steam"

	add_to_steam "zsnes" "$ZSNES_emuName" \
		"$toolsPath/launchers/zsnes.sh" \
		"$emusFolder/zsnes" \
		"$emudeckBackend/icons/ZSNES.png" \
		"Emulation"
}

ZSNES_update(){
	echo "NYI"
}
