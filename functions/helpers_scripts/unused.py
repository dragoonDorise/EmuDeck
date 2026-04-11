from core.all import *

def bool_from(val):
	if isinstance(val, bool):
		return val
	if val is None:
		return False
	return str(val).lower() in ("1", "true", "yes", "y")
def controller_layout_ABXY():
    Cemu_setABXYstyle()
    Azahar_setABXYstyle()
    Dolphin_setABXYstyle()
    melonDS_setABXYstyle()
    RetroArch_setABXYstyle()
    RMG_setABXYstyle()
    Ryujinx_setABXYstyle()

def controller_layout_BAYX():
    return True
    Cemu_setBAYXstyle()
    Dolphin_setBAYXstyle()
    Azahar_setBAYXstyle()
    melonDS_setBAYXstyle()
    RetroArch_setBAYXstyle()
    RMG_setBAYXstyle()
    Ryujinx_setBAYXstyle()

def download_file(url: str, dest: Path, show_progress: bool = True) -> bool:
        dest.parent.mkdir(parents=True, exist_ok=True)
        cmd = ["curl", "-L", "-o", str(dest), url]
        if not show_progress:
            cmd.insert(1, "-s")
        return subprocess.run(cmd).returncode == 0

def changeLine(KEYWORD: str, REPLACE: str, FILE: str) -> None:
    print(f"Updating: {FILE} - {KEYWORD} to {REPLACE}")

    path = Path(FILE)
    lines = path.read_text(encoding='utf-8').splitlines(keepends=True)

    new_lines = []
    for line in lines:
        if line.startswith(KEYWORD):
            new_lines.append(REPLACE.rstrip('\n') + '\n')
        else:
            new_lines.append(line)

    path.write_text(''.join(new_lines), encoding='utf-8')

def escapeSedKeyword(INPUT: str) -> str:
    specials = set(']/$*.^[')
    return ''.join(f'\\{ch}' if ch in specials else ch for ch in INPUT)

def escapeSedValue(INPUT: str) -> str:
    return ''.join(f'\\{ch}' if ch in {'/', '&'} else ch for ch in INPUT)

def deleteConfigs():
    root = Path(emudeck_backend) / "configs" / "org.libretro.RetroArch" / "config" / "retroarch" / "config"
    if not root.is_dir():
        return

    for p in root.rglob('*'):
        if p.is_file() and p.suffix.lower() in ('.opt', '.cfg'):
            try:
                p.unlink()
                print(f"Deleted: {p}")
            except Exception as e:
                print(f"Failed to delete {p}: {e}")

def customLocation() -> Optional[str]:
    try:
        result = subprocess.check_output(
            [
                "zenity",
                "--file-selection",
                "--directory",
                "--title=Select a destination for the Emulation directory."
            ],
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
        return result or None
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

def moveSaveFolder(emu: str, folderName: str, path: str, saves_path: str, set_msg) -> None:
    link_path = Path(saves_path) / emu / folderName
    try:
        linkedTarget = Path(link_path).resolve(strict=True)
    except FileNotFoundError:
        print(f"No link at {link_path} to move from.")
        return

    link_path.unlink()

    if not link_path.exists():
        link_path.mkdir(parents=True, exist_ok=True)
        if str(linkedTarget) == str(path):
            set_msg(f"Moving {emu} {folderName} to the Emulation/saves/{emu}/{folderName} folder")
            shutil.copytree(path, str(link_path), dirs_exist_ok=True)
            bak_path = Path(path + ".bak")
            shutil.move(path, bak_path)
            Path(path).symlink_to(link_path, target_is_directory=True)
            print(f"Moved and linked: {path} → {link_path} (original backed up to {bak_path})")

def iniFieldUpdate(iniFile: str,
                           iniSection: str = "",
                           iniKey: str = "",
                           iniValue: str = "",
                           separator: str = " = ") -> None:
    path = Path(iniFile)
    if not path.is_file():
        print(f"Can't update missing INI file: {iniFile}")
        return

    lines = path.read_text(encoding='utf-8').splitlines(keepends=True)
    section_header = f"[{iniSection}]" if iniSection else ""
    start_idx = end_idx = None

    if iniSection:
        for i, line in enumerate(lines):
            if line.strip() == section_header:
                start_idx = i
                break
        if start_idx is not None:
            for j in range(start_idx + 1, len(lines)):
                if lines[j].lstrip().startswith("[") and lines[j].rstrip().endswith("]"):
                    end_idx = j - 1
                    break
            else:
                end_idx = len(lines) - 1

    def is_key_line(line: str) -> bool:
        return line.startswith(f"{iniKey}{separator}")

    updated = False

    if iniSection and start_idx is None:
        print(f"Creating Header {section_header}")
        if len(lines) > 0 and not lines[-1].endswith("\n"):
            lines[-1] = lines[-1] + "\n"
        lines.append(f"{section_header}\n")
        print(f"Creating {section_header} key {iniKey}{separator}{iniValue}")
        lines.append(f"{iniKey}{separator}{iniValue}\n")
        updated = True
    elif iniSection and start_idx is not None:
        block = lines[start_idx+1:end_idx+1] if end_idx is not None else lines[start_idx+1:]
        if not any(is_key_line(l) for l in block):
            print(f"Creating {section_header} key {iniKey}{separator}{iniValue}")
            insert_pos = start_idx + 1
            lines.insert(insert_pos, f"{iniKey}{separator}{iniValue}\n")
            updated = True
        else:
            print(f"Updating {section_header} key {iniKey}{separator}{iniValue}")
            for k in range(start_idx+1, (end_idx or len(lines)-1) + 1):
                if is_key_line(lines[k]):
                    lines[k] = f"{iniKey}{separator}{iniValue}\n"
                    updated = True
                    break
    else:
        if not any(is_key_line(l) for l in lines):
            print(f"Creating key {iniKey}{separator}{iniValue}")
            if not lines[-1].endswith("\n"):
                lines[-1] = lines[-1] + "\n"
            lines.append(f"{iniKey}{separator}{iniValue}\n")
            updated = True
        else:
            print(f"Updating key {iniKey}{separator}{iniValue}")
            for i, line in enumerate(lines):
                if is_key_line(line):
                    lines[i] = f"{iniKey}{separator}{iniValue}\n"
                    updated = True
                    break

    if updated:
        path.write_text(''.join(lines), encoding='utf-8')

def iniSectionUpdate(file: str, section_name: str, new_content: str) -> None:
    path = Path(file)
    if not path.is_file():
        print(f"INI file not found: {file}")
        return

    lines = path.read_text(encoding='utf-8').splitlines(keepends=True)
    header = f'[{section_name}]'

    start_idx = None
    for i, line in enumerate(lines):
        if line.strip() == header:
            start_idx = i
            break

    if start_idx is None:
        print(f"Section {header} not found in {file}")
        return

    end_idx = len(lines)
    for j in range(start_idx + 1, len(lines)):
        l = lines[j]
        if l.lstrip().startswith('[') and l.rstrip().endswith(']'):
            end_idx = j
            break

    new_block = []
    for part in new_content.splitlines():
        new_block.append(part + "\n")
    if not new_content.endswith("\n"):
        new_block.append("\n")

    updated = lines[: start_idx + 1] + new_block + lines[end_idx :]

    path.write_text(''.join(updated), encoding='utf-8')

def addSteamInputCustomIcons():
    src = Path(emudeck_backend) / "configs" / "steam-input" / "Icons"
    dest = Path.home() / ".steam" / "steam" / "tenfoot" / "resource" / "images" / "library" / "controller" / "binding_icons"

    if not src.is_dir():
        print(f"Source icons directory not found: {src}")
        return

    dest.mkdir(parents=True, exist_ok=True)

    for item in src.rglob('*'):
        rel = item.relative_to(src)
        target = dest / rel
        if item.is_dir():
            target.mkdir(parents=True, exist_ok=True)
        else:
            shutil.copy2(item, target)
            print(f"Copied {item} → {target}")

def check_internet_connection() -> bool:
    try:
        result = subprocess.run(
            ["ping", "-q", "-c", "1", "-W", "1", "8.8.8.8"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        return result.returncode == 0
    except Exception:
        return False

def zip_logs() -> bool:
    from core.vars import emudeck_logs, emudeck_folder

    try:
        desktop = Path(subprocess.check_output(
            ["xdg-user-dir", "DESKTOP"], stderr=subprocess.DEVNULL, text=True
        ).strip())
        if not desktop.exists():
            raise Exception
    except Exception:
        desktop = Path.home() / "Desktop"

    logs_folder   = Path(emudeck_logs)
    settings_file = Path(emudeck_folder) / "settings.sh"
    zip_output    = desktop / "emudeck_logs.zip"

    try:
        with zipfile.ZipFile(zip_output, "w", zipfile.ZIP_DEFLATED) as zf:
            if logs_folder.is_dir():
                for f in logs_folder.rglob('*'):
                    if f.is_file():
                        arcname = f.relative_to(logs_folder.parent)
                        zf.write(f, arcname)
            if settings_file.is_file():
                zf.write(settings_file, settings_file.name)
        return True
    except Exception as e:
        print(f"zip_logs error: {e}")
        return False

def setResolutions():
    Cemu_setResolution()
    Azahar_setResolution()
    Dolphin_setResolution()
    DuckStation_setResolution()
    Flycast_setResolution()
    MAME_setResolution()
    melonDS_setResolution()
    mGBA_setResolution()
    PCSX2QT_setResolution()
    PPSSPP_setResolution()
    Primehack_setResolution()
    RPCS3_setResolution()
    Ryujinx_setResolution()
    ScummVM_setResolution()
    Vita3K_setResolution()
    Xemu_setResolution()
    Xenia_setResolution()
    Yuzu_setResolution()

def removeParser(custom_parser: str) -> None:
    source = Path(emudeck_backend) / "configs" / "steam-rom-manager" / "userData" / "parsers" / "optional"
    parser_path = source / custom_parser

    if not parser_path.is_file():
        print(f"El parser {custom_parser} no existe en {source}")
        return

    with parser_path.open(encoding='utf-8') as f:
        parser_cfg = json.load(f)
    parser_id = parser_cfg.get("parserId")
    print(f"Parser ID a eliminar: {parser_id}")

    srm_path = Path(SRM_userConfigurations)
    if not srm_path.is_file():
        print("El archivo de configuración no existe.")
        return

    with srm_path.open(encoding='utf-8') as f:
        try:
            configs = json.load(f)
            if not isinstance(configs, list):
                raise ValueError
        except Exception:
            print("Configuración inválida, abortando.")
            return

    new_configs = [cfg for cfg in configs if cfg.get("parserId") != parser_id]
    if len(new_configs) == len(configs):
        print(f"El parser {parser_id} no se encontró en la configuración.")
        return

    print("Eliminando parser...")
    try:
        SRM_setEmulationFolder()
    except NameError:
        print("NYI SRM_setEmulationFolder")

    new_configs.sort(key=lambda x: x.get("configTitle", ""))
    srm_path.write_text(json.dumps(new_configs, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')

def scriptConfigFileGetVar(configFile: str,
                           configVar: str,
                           configVarDefaultValue: str) -> str:
    path = Path(configFile)
    value = None

    if path.is_file():
        try:
            with path.open(encoding='utf-8') as f:
                for line in f:
                    if line.startswith(f"{configVar}="):
                        _, rhs = line.split("=", 1)
                        value = rhs.strip()
                        break
        except Exception:
            value = None

    if value is None or value == "":
        return configVarDefaultValue
    return value

def getEmuRepo(name: str) -> str:
    mapping = {
        "cemu":       "cemu-project/Cemu",
        "azahar":     "azahar-emu/azahar",
        "dolphin":    "shiiion/dolphin",
        "duckstation":"stenzek/duckstation",
        "flycast":    "flyinghead/flycast",
        "MAME":       "mamedev/mame",
        "melonDS":    "melonDS-emu/melonDS",
        "mgba":       "mgba-emu/mgba",
        "pcsx2":      "pcsx2/pcsx2",
        "primehack":  "shiiion/dolphin",
        "rpcs3":      "RPCS3/rpcs3-binaries-win",
        "ryujinx":    "Ryujinx/release-channel-master",
        "vita3K":     "Vita3K/Vita3K",
        "xemu":       "xemu-project/xemu",
        "xenia":      "xenia-canary/xenia-canary",
        "yuzu":       "yuzu-emu/yuzu-mainline",
    }
    return mapping.get(name, "none")

def getLatestVersionGH(repository: str) -> str:
    url = f"https://api.github.com/repos/{repository}/releases/latest"
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    data = resp.json()
    return str(data.get("id", ""))

def addProtonLaunch():

    backend_tools = Path(emudeck_backend) / "tools"
    dst = Path(tools_path) / "launchers"

    for fname in ("proton-launch.sh", "appID.py"):
        src = backend_tools / fname
        if not src.is_file():
            print(f"Source not found: {src}")
            continue
        dst.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst / fname)
        print(f"Copied {src} → {dst / fname}")

    pl = dst / "proton-launch.sh"
    if pl.is_file():
        pl.chmod(pl.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        print(f"Made executable: {pl}")
    else:
        print(f"File not found for chmod: {pl}")

def store_patreon_token(token: str) -> None:
    token_file = Path(saves_path) / ".token"
    token_file.parent.mkdir(parents=True, exist_ok=True)
    token_file.write_text(token, encoding='utf-8')
    print(f"Stored token in {token_file}")
    if Path(cloud_sync_bin).is_file():
        cmd = [
            cloud_sync_bin,
            "--progress", "copyto", "-L",
            "--fast-list",
            "--checkers=50", "--transfers=50",
            "--low-level-retries", "1", "--retries", "1",
            str(token_file),
            f"{cloud_sync_provider}:{cs_user}Emudeck/saves/.token"
        ]
        subprocess.run(cmd)

def startCompressor() -> None:
   
    script = Path(emudeck_backend) / "tools" / "chdconv" / "chddeck.sh"
    if not script.is_file():
        print(f"Compressor script not found: {script}")
        return
    cmd = ["konsole", "-e", "/bin/bash", str(script)]
    subprocess.Popen(cmd)
    print(f"Started compressor via: {' '.join(cmd)}")

def popup_ask_conflict(title: str, message: str) -> Optional[bool]:
    app = ensure_app()
    dlg = BaseDialog(title)

    lbl = QtWidgets.QLabel(message)
    lbl.setWordWrap(True)
    dlg._add(lbl)

    btn_layout = QtWidgets.QHBoxLayout()
    yes_btn = QtWidgets.QPushButton("Yes")
    no_btn  = QtWidgets.QPushButton("No")
    ca_btn  = QtWidgets.QPushButton("Cancel")
    btn_layout.addWidget(yes_btn)
    btn_layout.addWidget(no_btn)
    btn_layout.addWidget(ca_btn)
    dlg._inner.addLayout(btn_layout)

    widgets = [yes_btn, no_btn, ca_btn]
    widgets[0].setFocus()
    idx = 0

    choice: Optional[str] = None
    def _set(c: str, accept: bool):
        nonlocal choice
        choice = c
        if accept:
            dlg.accept()
        else:
            dlg.reject()

    yes_btn.clicked.connect(lambda: _set("yes"))
    no_btn.clicked.connect(lambda: _set("no"))
    ca_btn.clicked.connect(lambda: _set("cancel"))

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        dir = poll_gamepad_dir()
        if dir == "right":
            idx = (idx + 1) % len(widgets)
            widgets[idx].setFocus()
        elif dir == "left":
            idx = (idx - 1) % len(widgets)
            widgets[idx].setFocus()
        elif dir in ("up","down"):
            idx = (idx + (1 if dir=="down" else -1)) % len(widgets)
            widgets[idx].setFocus()
        gp = poll_gamepad()
        if gp in ("yes","no","cancel"):
            _set(gp)
        QtCore.QThread.msleep(50)

    return {"yes": True, "no": False, "cancel": None}.get(choice)

def popup_ask_string(prompt: str, title: str = "Input") -> Optional[str]:
    app = ensure_app()
    dlg = BaseDialog(title)

    lbl = QtWidgets.QLabel(prompt)
    lbl.setWordWrap(True)
    dlg._add(lbl)

    le = QtWidgets.QLineEdit()
    dlg._add(le)

    buttons = QtWidgets.QDialogButtonBox(
        QtWidgets.QDialogButtonBox.Ok | QtWidgets.QDialogButtonBox.Cancel
    )
    buttons.accepted.connect(dlg.accept)
    buttons.rejected.connect(dlg.reject)
    dlg._add(buttons, alignment=QtCore.Qt.AlignCenter)

    dlg.show()
    accepted = False
    while dlg.isVisible():
        app.processEvents()
        gp = poll_gamepad()
        if gp == "yes":
            accepted = True; dlg.accept()
        if gp == "no":
            dlg.reject()
        QtCore.QThread.msleep(50)

    if dlg.result() == QtWidgets.QDialog.Accepted:
        txt = le.text().strip()
        return txt or None
    return None

def popup_ask_password(prompt: str, title: str = "Password") -> Optional[str]:
    app = ensure_app()
    dlg = BaseDialog(title)

    lbl = QtWidgets.QLabel(prompt)
    lbl.setWordWrap(True)
    dlg._add(lbl)

    le = QtWidgets.QLineEdit()
    le.setEchoMode(QtWidgets.QLineEdit.Password)
    dlg._add(le)

    buttons = QtWidgets.QDialogButtonBox(
        QtWidgets.QDialogButtonBox.Ok | QtWidgets.QDialogButtonBox.Cancel
    )
    buttons.accepted.connect(dlg.accept)
    buttons.rejected.connect(dlg.reject)
    dlg._add(buttons, alignment=QtCore.Qt.AlignCenter)

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        gp = poll_gamepad()
        if gp == "yes":
            dlg.accept()
        if gp == "no":
            dlg.reject()
        QtCore.QThread.msleep(50)

    if dlg.result() == QtWidgets.QDialog.Accepted:
        pw = le.text()
        return pw or None
    return None

def get_locations():
    import wmi
    c = wmi.WMI()
    drive_info = []

    for net in c.Win32_LogicalDisk(DriveType=4):
        if not net.VolumeName or not net.Size:
            continue
        try:
            size_gb = round(int(net.Size) / (1024**3), 2)
        except Exception:
            continue
        drive_info.append({
            "name":   net.VolumeName,
            "size":   size_gb,
            "type":   "Network",
            "letter": net.DeviceID,
        })

    for disk in c.Win32_DiskDrive():
        media = disk.MediaType or ""
        if "Fixed hard disk media" in media:
            dtype = "Internal"
        elif "Removable media" in media:
            dtype = "External"
        else:
            dtype = "Unknown"

        for part in disk.associators("Win32_DiskDriveToDiskPartition"):
            for ld in part.associators("Win32_LogicalDiskToPartition"):
                if not ld.DeviceID or not disk.Size:
                    continue
                try:
                    size_gb = round(int(disk.Size) / (1024**3), 2)
                except Exception:
                    continue
                drive_info.append({
                    "name":   disk.Model.strip(),
                    "size":   size_gb,
                    "type":   dtype,
                    "letter": ld.DeviceID,
                })

    drive_info.sort(key=lambda d: d["letter"])

    if not drive_info:
        drive_info = [{
            "type":   "Internal",
            "letter": "C:",
            "name":   "harddisk SSD",
            "size":   999
        }]

    return drive_info

def calculate_md5_without_header(
        file: Union[str, Path],
        header_size: int,
        chunk_size: int = 8192
    ) -> str:
        file_path = Path(file)
        md5 = hashlib.md5()
        with file_path.open('rb') as f:
            f.seek(header_size)
            for chunk in iter(lambda: f.read(chunk_size), b''):
                md5.update(chunk)
        return md5.hexdigest()

def cloud_decky_check_status():
    return "started"
    

def get_emu_install_status(*emu_array):
    emulators = []
    for emu in emu_array:
        func_name = f"{emu}_is_installed"
        try:
            func = globals().get(func_name)
            if not func:
                import sys
                for module in sys.modules.values():
                    func = getattr(module, func_name, None)
                    if func:
                        break
            
            if func:
                installed = func()
            else:
                installed = "false"
        except Exception:
            installed = "false"
    
        emulators.append({
            "Name": emu,
            "Installed": installed
        })
    
    return json.dumps({"Emulators": emulators})
    
