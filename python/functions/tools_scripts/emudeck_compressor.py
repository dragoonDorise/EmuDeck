from core.all import *
import struct


chd_folder_whitelist = [
    "3do", "amiga", "amiga600", "amiga1200",
    "amigacd32", "atomiswave", "cdimono1",
    "cdtv", "dreamcast", "genesis", "genesiswide",
    "megacd", "megacdjp", "megadrive", "megadrivejp",
    "naomi", "naomi2", "naomigd", "neogeocd",
    "neogeocdjp", "pcenginecd", "pcfx",
    "ps2", "psx", "saturn", "saturnjp",
    "sega32x", "sega32xjp", "sega32xna",
    "segacd", "tg-cd", "tg16"
]

rvz_folder_whitelist = [
    "gc", "wii", "primehacks"
]

cso_folder_whitelist = [
    "psp"
]

n3ds_folder_whitelist = [
    "n3ds"
]

xbox_folder_whitelist = [
    "xbox"
]

sevenzip_folder_whitelist = [
    "atari2600", "atarilynx", "famicom", "gamegear",
    "gb", "gbc", "gba", "genesis", "mastersystem",
    "megacd", "n64", "n64dd", "nes", "ngp",
    "ngpc", "saturn", "sega32x", "segacd",
    "sfc", "snes", "snesna", "wonderswan",
    "wonderswancolor"
]

search_folder_list: list[str] = []


chd_file_extensions = ["gdi", "cue", "iso", "chd"]
rvz_file_extensions = ["gcm", "iso", "rvz"]
cso_file_extensions = ["iso", "cso"]
xbox_file_extensions = ["iso"]
n3ds_file_extensions = ["3ds"]
sevenzip_file_extensions = [
    "ngp", "ngc", "a26", "lnx", "ws", "pc2",
    "wsc", "n64", "ndd", "v64", "z64",
    "gb", "dmg", "gba", "gbc", "nes",
    "fds", "unf", "unif", "bs", "fig",
    "sfc", "smc", "swx", "32x", "gg",
    "gen", "md", "smd"
]

compressor_tools_dir = Path(emudeck_folder) / "compressor-tools"
if system.startswith("win"):
    chd_path = compressor_tools_dir / "win_x86"
    chdman_cmd = str(chd_path / "chdman.exe")
    ciso_cmd = str(chd_path / "ciso.exe")
    tool_cmd = str(chd_path / "3dstool.exe")
    extract_cmd = str(chd_path / "extract-xiso.exe")
elif system == "darwin":
    chd_path = compressor_tools_dir / "darwin"
    chdman_cmd = str(chd_path / "chdman")
    ciso_cmd = None
    tool_cmd = None
    extract_cmd = str(chd_path / "extract-xiso")
else:
    chd_path = compressor_tools_dir / ("arm64" if cpu_arch == "arm" else "x86")
    chdman_cmd = str(chd_path / "chdman5")
    ciso_cmd = str(chd_path / "ciso")
    tool_cmd = str(chd_path / "3dstool")
    extract_cmd = str(chd_path / "extract-xiso")

def compressor_install_tools() -> None:
    if system == "darwin":
        if Path(extract_cmd).exists():
            return
        url = get_latest_release_gh("XboxDev/extract-xiso", "zip", "macOS")
    else:
        if Path(chdman_cmd).exists():
            return
        url = get_latest_release_gh("EmuDeck/compressor-tools", "zip", chd_path.name, "" if system.startswith("win") else "win")
    if not url:
        print("Unable to find the compressor tools download")
        return
    chd_path.mkdir(parents=True, exist_ok=True)
    archive = chd_path / "tools.zip"
    response = requests.get(url, stream=True, timeout=30)
    response.raise_for_status()
    with open(archive, "wb") as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)
    zipfile.ZipFile(archive).extractall(chd_path if system == "darwin" else compressor_tools_dir)
    archive.unlink(missing_ok=True)
    for exe in filter(None, [chdman_cmd, ciso_cmd, tool_cmd, extract_cmd]):
        if Path(exe).exists():
            Path(exe).chmod(Path(exe).stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

def cso_compress_file(src: Path, dst: Path, level: int = 9) -> None:
    block_size = 2048
    total = src.stat().st_size
    blocks = (total + block_size - 1) // block_size
    with open(src, "rb") as fi, open(dst, "wb") as fo:
        fo.write(struct.pack("<4sIQIBB2x", b"CISO", 0x18, total, block_size, 1, 0))
        fo.write(b"\0" * 4 * (blocks + 1))
        index = []
        for _ in range(blocks):
            data = fi.read(block_size)
            offset = fo.tell()
            packer = zlib.compressobj(level, zlib.DEFLATED, -15)
            packed = packer.compress(data) + packer.flush()
            if len(packed) >= len(data):
                index.append(offset | 0x80000000)
                fo.write(data)
            else:
                index.append(offset)
                fo.write(packed)
        index.append(fo.tell())
        if index[-1] >= 0x80000000:
            raise ValueError("CSO output bigger than 2GB is not supported")
        fo.seek(0x18)
        fo.write(struct.pack(f"<{blocks + 1}I", *index))

def cso_decompress_file(src: Path, dst: Path) -> None:
    with open(src, "rb") as fi, open(dst, "wb") as fo:
        magic, header_size, total, block_size, version, align = struct.unpack("<4sIQIBB2x", fi.read(0x18))
        if magic != b"CISO":
            raise ValueError(f"{src.name} is not a CSO file")
        blocks = (total + block_size - 1) // block_size
        fi.seek(header_size)
        index = struct.unpack(f"<{blocks + 1}I", fi.read(4 * (blocks + 1)))
        for i in range(blocks):
            start = (index[i] & 0x7FFFFFFF) << align
            end = (index[i + 1] & 0x7FFFFFFF) << align
            fi.seek(start)
            data = fi.read(end - start)
            if not index[i] & 0x80000000:
                data = zlib.decompressobj(-15).decompress(data)
            fo.write(data[:block_size])
        fo.truncate(total)

def trim_3ds_file(path: Path) -> bool:
    with open(path, "r+b") as f:
        f.seek(0x100)
        if f.read(4) != b"NCSD":
            return False
        f.seek(0x120)
        table = struct.unpack("<16I", f.read(0x40))
        f.seek(0x18E)
        media_unit = 0x200 << f.read(1)[0]
        f.truncate(max(table[i * 2] + table[i * 2 + 1] for i in range(8)) * media_unit)
    return True

def compress_chd(file_path: Path) -> None:
    file_path = Path(file_path)
    output_path = file_path.with_suffix('.chd')
    cuedir = file_path.parent
    file_type = file_path.suffix.lstrip('.').lower()

    print(f"Compressing {output_path.name}")

    # Run chdman createcd
    result = subprocess.run(
        [chdman_cmd, "createcd", "-i", str(file_path), "-o", str(output_path)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    if result.returncode == 0:
        print(f"Converting {file_path.name} to CHD using the createcd flag.")
        print(f"{file_path.name} successfully converted to {output_path.name}")

        # If original wasn't an ISO, remove matching cue/bin tracks
        if file_type != "iso":
            for sibling in cuedir.iterdir():
                if not sibling.is_file():
                    continue
                name = sibling.name
                # Check if this filename appears inside the original cue/bin file
                try:
                    content = file_path.read_text(encoding="utf-8", errors="ignore")
                except Exception:
                    content = ""
                if name in content:
                    print(f"Deleting {name}")
                    sibling.unlink(missing_ok=True)

        # Remove the original file
        file_path.unlink(missing_ok=True)
    else:
        print(f"Conversion of {file_path.name} failed.")
        # Clean up any partial output
        output_path.unlink(missing_ok=True)

def compress_chd_dvd(
            file_path: Path,
            mode: str = "createdvd",
            zstd: bool = True,
            hunksize: Optional[int] = None
        ) -> None:
    file_path = Path(file_path)
    output_path = file_path.with_suffix('.chd')

    # Build command
    cmd = [chdman_cmd, mode, "-i", str(file_path), "-o", str(output_path)]
    if zstd:
        cmd.extend(["-c", "zstd"])
    if hunksize is not None:
        cmd.extend(["--hunksize", str(hunksize)])

    # Run the conversion
    result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    if result.returncode == 0:
        hs_text = f" and hunksize {hunksize}" if hunksize is not None else ""
        alg_text = " with zstd" if zstd else ""
        print(f"Converting {file_path.name} to CHD using `{mode}` flag{hs_text}{alg_text}.")
        print(f"{file_path.name} successfully converted to {output_path.name}")
        # Remove the original file
        file_path.unlink(missing_ok=True)
    else:
        print(f"Conversion of {file_path.name} failed.")
        # Clean up any partial output
        output_path.unlink(missing_ok=True)

def compress_chd_dvd_lower_hunk(file_path: Path) -> None:
    compress_chd_dvd(file_path, "createdvd", False, 2048)

def decompress_chd_iso(
        file_path: Path
    ) -> None:
    file_path = Path(file_path)
    output_path = file_path.with_suffix(".iso")

    cmd = [chdman_cmd, "extractdvd", "-i", str(file_path), "-o", str(output_path)]

    result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    if result.returncode == 0:
        print(f"Decompressing {file_path.name} to ISO using the extractdvd flag.")
        print(f"{file_path.name} successfully decompressed to {output_path.name}")
        # Remove the original CHD
        file_path.unlink(missing_ok=True)
    else:
        print(f"Decompression of {file_path.name} failed.")
        # Clean up any partial output
        output_path.unlink(missing_ok=True)

def compress_rvz(
            file_path: Path,
            flatpak_cmd: str = "flatpak",
            dolphin_tool_name: str = "dolphin-tool"
        ) -> None:
    file_path = Path(file_path)
    output_path = file_path.with_suffix(".rvz")
    windows_tool = f"{emudeck_folder}/Emulators/Dolphin-x64/DolphinTool.exe";

    if system.startswith("win"):
        # Windows path: use the provided exe
        if not windows_tool:
            print("Error: on Windows you must provide windows_tool path to dolphin-tool.exe")
            return

        cmd = [
            str(windows_tool),
            "convert",
            "-f", "rvz",
            "-b", "131072",
            "-c", "zstd",
            "-l", "5",
            "-i", str(file_path),
            "-o", str(output_path),
        ]

    if system.startswith("linux"):
        # 1) Detect which Flatpak contains dolphin-tool
        try:
            flatpak_list = subprocess.check_output(
                [flatpak_cmd, "list", "--columns=application"],
                text=True,
                stderr=subprocess.DEVNULL
            )
        except subprocess.CalledProcessError:
            print("Error: Unable to list Flatpak applications.")
            return

        # 2) Pick the first matching Dolphin/PrimeHack Flatpak
        flatpak_app: Optional[str] = None
        for line in flatpak_list.splitlines():
            if "dolphin" in line.lower() or "primehack" in line.lower():
                flatpak_app = line.strip()
                break

        if not flatpak_app:
            print("Error: No Dolphin or PrimeHack Flatpak found.")
            return

        # 3) Build the command
        cmd = [
            flatpak_cmd, "run",
            "--command=" + dolphin_tool_name, flatpak_app,
            "convert",
            "-f", "rvz",
            "-b", "131072",
            "-c", "zstd",
            "-l", "5",
            "-i", str(file_path),
            "-o", str(output_path),
        ]

    # 4) Run the conversion
    res = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if res.returncode == 0:
        print(f"{file_path.name} successfully converted to {output_path.name}")
        file_path.unlink(missing_ok=True)
    else:
        print(f"Error converting {file_path.name}")
        output_path.unlink(missing_ok=True)

def compress_cso(file_path: Path) -> None:
    file_path = Path(file_path)
    output_path = file_path.with_suffix(".cso")

    if system == "darwin":
        try:
            cso_compress_file(file_path, output_path)
            returncode = 0
        except Exception as e:
            print(e)
            returncode = 1
    else:
        returncode = subprocess.run(
            [ciso_cmd, "9", str(file_path), str(output_path)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        ).returncode

    if returncode == 0:
        print(f"{file_path.name} successfully converted to {output_path.name}")
        try:
            file_path.unlink()
        except Exception as e:
            print(f"Could not remove original file: {e}")
    else:
        print(f"Error converting {file_path.name} to CSO")
        # remove any incomplete output
        try:
            output_path.unlink(missing_ok=True)
        except Exception:
            pass

def trim_3ds(file_path: Path) -> None:
    file_path = Path(file_path)
    if system == "darwin":
        returncode = 0 if trim_3ds_file(file_path) else 1
    else:
        returncode = subprocess.run(
            [tool_cmd, "-r", "-f", str(file_path)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        ).returncode

    if returncode == 0:
        trimmed_name = file_path.with_name(f"{file_path.stem}(Trimmed){file_path.suffix}")
        try:
            file_path.rename(trimmed_name)
            print(f"Successfully trimmed {file_path.name} → {trimmed_name.name}")
        except Exception as e:
            print(f"Trim succeeded but failed to rename file: {e}")
    else:
        print(f"Error trimming {file_path.name}")

def compress_xiso(file_path: Path) -> None:
    file_path = Path(file_path)
    xiso_dir = file_path.parent
    output_name = f"{file_path.stem}.xiso.iso"
    output_path = xiso_dir / output_name
    old_iso_old = xiso_dir / f"{file_path.stem}.iso.old"

    # Run the conversion command
    result = subprocess.run(
        [extract_cmd, "-r", str(file_path), "-d", str(xiso_dir)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

    if result.returncode == 0:
        # Conversion succeeded
        print(f"{file_path.name} successfully converted to {output_name}")
        try:
            # Rename the original file to the new .xiso.iso name
            file_path.rename(output_path)
        except Exception as e:
            print(f"Conversion succeeded but failed to rename file: {e}")
        # Remove any leftover .iso.old file
        try:
            old_iso_old.unlink(missing_ok=True)
        except Exception:
            pass
    else:
        # Conversion failed
        print(f"Error converting {file_path.name} to XISO")

def decompress_cso_iso(cso_path: Path) -> None:
    cso_path = Path(cso_path)
    iso_path = cso_path.with_suffix(".iso")

    if system == "darwin":
        try:
            cso_decompress_file(cso_path, iso_path)
            returncode = 0
        except Exception as e:
            print(e)
            returncode = 1
    else:
        returncode = subprocess.run([ciso_cmd, "0", str(cso_path), str(iso_path)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode
    if returncode == 0:
        print(f"{cso_path.name} successfully converted to {iso_path.name}")
        try:
            cso_path.unlink()
        except Exception as e:
            print(f"Decompressed but failed to delete {cso_path.name}: {e}")
    else:
        print(f"Error converting {cso_path.name} to ISO")
        if iso_path.exists():
            try:
                iso_path.unlink()
            except Exception:
                pass

def decompress_rvz(rvz_path: Path) -> None:
    rvz_path = Path(rvz_path)
    if not rvz_path.is_file():
        print(f"File not found: {rvz_path}")
        return

    if system == "linux":
        tool_cmd = ["flatpak", "run", "--command=dolphin-tool", "org.DolphinEmu.dolphin-emu"]
    elif system.startswith("win"):
        tool_cmd = [f"{emudeck_folder}/Emulators/Dolphin-x64/DolphinTool.exe"]
    elif system == "darwin":
        # Inside Dolphin.app bundle
        default = Path(emus_folder) / "Dolphin.app" / "Contents" / "MacOS" / "dolphin-tool"
        if default.exists():
            tool_cmd = [str(default)]
        else:
            print(f"dolphin-tool not found in {default.parent}")
            return
    else:
        print(f"Unsupported OS: {system}")
        return

    iso_path = rvz_path.with_suffix('.iso')
    cmd = [
        *tool_cmd,
        "convert",
        "-f", "iso",
        "-b", "131072",
        "-c", "zstd",
        "-l", "5",
        "-i", str(rvz_path),
        "-o", str(iso_path),
    ]

    res = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if res.returncode == 0:
        print(f"{rvz_path.name} → {iso_path.name}")
        try:
            rvz_path.unlink()
        except Exception as e:
            print(f"Could not delete original {rvz_path.name}: {e}")
    else:
        print(f"Error converting {rvz_path.name}")
        if iso_path.exists():
            try:
                iso_path.unlink()
            except Exception:
                pass

def popup_ask_compressor(title: str, message: str) -> Optional[bool]:
    app = ensure_app()
    dlg = BaseDialog(title)

    lbl = QtWidgets.QLabel(message)
    lbl.setWordWrap(True)
    dlg._add(lbl)

    # Botones
    btn_layout = QtWidgets.QHBoxLayout()
    yes_btn = QtWidgets.QPushButton("Compress roms")
    no_btn  = QtWidgets.QPushButton("Decompress roms")
    btn_layout.addWidget(yes_btn)
    btn_layout.addWidget(no_btn)
    dlg._inner.addLayout(btn_layout)

    choice: Optional[str] = None
    def _set(c: str):
        nonlocal choice
        choice = c
        dlg.accept()

    yes_btn.clicked.connect(lambda: _set("yes"))
    no_btn.clicked.connect(lambda: _set("no"))

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        gp = poll_gamepad()
        if gp in ("yes","no"):
            _set(gp)
        QtCore.QThread.msleep(50)

    return {"yes": True, "no": False}.get(choice)

def popup_select_folder(
    title: str,
    message: str,
    candidates: Sequence[str]
) -> list:
    app = ensure_app()
    dlg = BaseDialog(title)

    names = {"psp": "PSP", "psx": "PlayStation", "ps2": "PlayStation 2", "gc": "GameCube", "wii": "Wii", "primehacks": "Metroid Prime (PrimeHack)",
             "n3ds": "Nintendo 3DS", "xbox": "Xbox", "dreamcast": "Dreamcast", "saturn": "Saturn", "saturnjp": "Saturn (JP)", "segacd": "Sega CD",
             "megacd": "Mega CD", "pcenginecd": "PC Engine CD", "neogeocd": "Neo Geo CD", "3do": "3DO", "naomi": "Naomi", "atomiswave": "Atomiswave"}

    lbl = QtWidgets.QLabel(message)
    lbl.setWordWrap(True)
    lbl.setStyleSheet("margin-bottom: 8px;")
    dlg._add(lbl)

    listw = QtWidgets.QListWidget()
    for folder in candidates:
        item = QtWidgets.QListWidgetItem(names.get(folder, folder.capitalize()))
        item.setData(QtCore.Qt.UserRole, folder)
        listw.addItem(item)
    listw.setSelectionMode(QtWidgets.QAbstractItemView.MultiSelection)
    listw.setMinimumHeight(min(len(candidates), 6) * 48 + 16)
    dlg._add(listw)

    btns = QtWidgets.QHBoxLayout()
    btns.addStretch()
    cancel = QtWidgets.QPushButton("Cancel")
    ok = QtWidgets.QPushButton("OK")
    btns.addWidget(cancel)
    btns.addWidget(ok)
    dlg._inner.addLayout(btns)

    choice: list = []

    def do_ok():
        nonlocal choice
        choice = [it.data(QtCore.Qt.UserRole) for it in listw.selectedItems()]
        dlg.accept()

    def do_cancel():
        nonlocal choice
        choice = []
        dlg.reject()

    ok.clicked.connect(do_ok)
    cancel.clicked.connect(do_cancel)

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        gp = poll_gamepad()
        if gp == "yes":
            do_ok()
        elif gp == "no":
            do_cancel()
        QtCore.QThread.msleep(50)

    return choice

def compressor_folder_has_files(folder: str, exts: list[str]) -> bool:
    d = roms_path / folder
    print(f"→ inspecting folder {d!r}")
    if not d.is_dir():
        print("   ✖ not a directory")
        return False

    # normalize extensions to ".ext" form, lowercase
    wanted = {f".{e.lower().lstrip('.')}" for e in exts}
    print(f"   looking for extensions: {wanted}")

    for f in d.rglob("*"):
        if not f.is_file():
            continue
        suf = f.suffix.lower()
        if suf in wanted:
            print(f"   ✔ matched file {f!r} (suffix={suf})")
            return True
    print("   ✖ no matching files found")
    return False

def compressor_generate_list(decompress: bool = False):
    # CHD folders
    candidates: List[str] = []
    for f in chd_folder_whitelist if Path(chdman_cmd).exists() else []:
        print(f"Checking {roms_path / f}")
        if compressor_folder_has_files(f, ["chd"] if decompress else ["gdi", "cue", "iso"]):
            print(f"found in {f}")
            candidates.append(f)

    # RVZ only if dolphin-tool available (i.e. flatpak on Linux):
    for f in rvz_folder_whitelist if system != "darwin" or (Path(emus_folder) / "Dolphin.app" / "Contents" / "MacOS" / "dolphin-tool").exists() else []:
        print(f"Checking {roms_path / f}")
        if compressor_folder_has_files(f, ["rvz"] if decompress else ["gcm", "iso"]):
            print(f"found in {f}")
            candidates.append(f)

    # 3DS
    for f in [] if decompress else n3ds_folder_whitelist:
        print(f"Checking {roms_path / f}")
        # ignore *Trimmed*
        d = roms_path / f
        if d.is_dir():
            for p in d.rglob("*.3ds"):
                if "Trimmed" not in p.name:
                    print(f"found in {f}")
                    candidates.append(f)
                    break

    # CSO (just .iso)
    for f in cso_folder_whitelist:
        print(f"Checking {roms_path / f}")
        if compressor_folder_has_files(f, ["cso"] if decompress else ["iso"]):
            print(f"found in {f}")
            candidates.append(f)

    # XBOX (exclude *.xiso.iso)
    for f in [] if decompress else xbox_folder_whitelist:
        print(f"Checking {roms_path / f}")
        d = roms_path / f
        if d.is_dir():
            for p in d.rglob("*.iso"):
                if not p.name.lower().endswith(".xiso.iso"):
                    print(f"found in {f}")
                    candidates.append(f)
                    break
    return candidates


def compressor_compress(romfolder: any):
    if romfolder is None:
        return
    base = roms_path / romfolder
    if romfolder is not None:
        if romfolder in chd_folder_whitelist:
            for ext in ("*.gdi", "*.cue"):
                for f in base.rglob(ext):
                    print(f"Converting: {f} using the createcd flag")
                    compress_chd(str(f))
            for f in base.rglob("*.iso"):
                print(f"Converting: {f} using the createdvd flag")
                compress_chd_dvd(str(f))

        elif romfolder in rvz_folder_whitelist:
            for pattern in ("*.gcm", "*.iso"):
                for f in base.rglob(pattern):
                    print(f"Converting: {f} to RVZ")
                    compress_rvz(str(f))

        elif romfolder in cso_folder_whitelist:
            for f in base.rglob("*.iso"):
                print(f"Converting: {f} to CSO")
                compress_cso(str(f))

        elif romfolder in n3ds_folder_whitelist:
            for f in base.rglob("*.3ds"):
                if "(Trimmed)" not in f.name:
                    print(f"Trimming: {f}")
                    trim_3ds(str(f))

        elif romfolder in xbox_folder_whitelist:
            for f in base.rglob("*.iso"):
                if not f.name.lower().endswith(".xiso.iso"):
                    print(f"Converting: {f} to XISO")
                    compress_xiso(str(f))
        else:
            print(f"No compression rules for '{romfolder}'")

def compressor_decompress(romfolder: any):
    if romfolder is None:
        return
    base = roms_path / romfolder
    if romfolder is not None:
        if romfolder in chd_folder_whitelist:
            for f in base.rglob("*.chd"):
                print(f"Decompressing: {f}")
                decompress_chd_iso(str(f))

        elif romfolder in rvz_folder_whitelist:
            for f in base.rglob("*.rvz"):
                print(f"Decompressing: {f}")
                decompress_rvz(str(f))

        elif romfolder in cso_folder_whitelist:
            for f in base.rglob("*.cso"):
                print(f"Decompressing: {f}")
                decompress_cso_iso(str(f))
        else:
            print(f"No decompression rules for '{romfolder}'")



def compressor_launch():
    compressor_install_tools()
    executables = [chdman_cmd, ciso_cmd, tool_cmd, extract_cmd]

    combined_file_extensions = (
        n3ds_file_extensions
        + chd_file_extensions
        + rvz_file_extensions
        + cso_file_extensions
        + xbox_file_extensions
        + sevenzip_file_extensions
    )

    for exe_name in filter(None, executables):
        exe_file = Path(exe_name)
        if exe_file.exists():
            # Lee el modo actual y añade el bit de ejecución para usuario, grupo y otros
            current_mode = exe_file.stat().st_mode
            exe_file.chmod(current_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
            print(f"Hecho ejecutable: {exe_file}")
        else:
            print(f"No encontrado (omitido): {exe_file}")

    resp = popup_ask_compressor(
        "EmuDeck Compressor",
        "Please Select an option"
    )

    if resp is True:
        # user chose Bulk compress
        print(f"🔍 Checking {roms_path} for files eligible for conversion.")

        folders = compressor_generate_list()

        if not folders:
            popup_show_info("EmuDeck Compressor", "No suitable ROMs were found for conversion.")
            return

        romfolders = popup_select_folder(
            "Choose Systems",
            "Select which systems you want to compress:",
            folders
        )

        if romfolders:
            popup_show_progress("EmuDeck Compressor", f"Compressing your {', '.join(romfolders)} games, this can take a while...", lambda: [compressor_compress(romfolder) for romfolder in romfolders])
            popup_show_info("EmuDeck Compressor", "All done! Check the log if any game failed.")

    elif resp is False:
        # user chose Bulk deompress
        print(f"🔍 Checking {roms_path} for files eligible for conversion.")

        folders = compressor_generate_list(True)

        if not folders:
            popup_show_info("EmuDeck Compressor", "No suitable ROMs were found for conversion.")
            return

        romfolders = popup_select_folder(
            "Choose Systems",
            "Select which systems you want to decompress:",
            folders
        )

        if romfolders:
            popup_show_progress("EmuDeck Compressor", f"Decompressing your {', '.join(romfolders)} games, this can take a while...", lambda: [compressor_decompress(romfolder) for romfolder in romfolders])
            popup_show_info("EmuDeck Compressor", "All done! Check the log if any game failed.")
