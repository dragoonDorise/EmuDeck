from core.all import *

def install():

    #
    # Create folders
    #
    emulation_path.mkdir(parents=True, exist_ok=True)
    roms_path.mkdir(parents=True, exist_ok=True)
    tools_path.mkdir(parents=True, exist_ok=True)
    bios_path.mkdir(parents=True, exist_ok=True)
    saves_path.mkdir(parents=True, exist_ok=True)
    storage_path.mkdir(parents=True, exist_ok=True)
    ESDEscrapData.mkdir(parents=True, exist_ok=True)

    # Copy roms estructure
    shutil.copytree(f"{emudeck_backend}/configs/common/roms", roms_path, dirs_exist_ok=True)


def get_sd_path() -> Optional[str]:

    """
    Equivalente a tu función Bash getSDPath:
    - Comprueba si /dev/mmcblk0p1 existe y es un dispositivo de bloque.
    - Si existe, invoca 'findmnt' para obtener el punto de montaje.
    - Devuelve la cadena vacía o None si no está presente.
    """
    sd_block = "/dev/mmcblk0p1"

    # 1) ¿Existe y es un bloque?
    try:
        st = os.stat(sd_block)
    except FileNotFoundError:
        return None

    if not stat.S_ISBLK(st.st_mode):
        return None

    # 2) Llamada a findmnt
    try:
        out = subprocess.check_output(
            ["findmnt", "-n", "--raw", "--evaluate", "--output=target", "-S", sd_block],
            text=True  # para obtener str en lugar de bytes
        ).strip()
        return out or None
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Puede fallar si findmnt no está instalado
        return None

def test_location_valid(location_name: str) -> str:
    """
    Comprueba si test_location:
      1) Está presente (no es None ni cadena vacía).
      2) No contiene espacios.
      3) Es escribible (podemos crear un fichero).
      4) Permite crear enlaces simbólicos.
    Devuelve "Valid" o "Invalid: <motivo>".
    """
    # 1) ¿Se pasó test_location?
    if not test_location:
        return f"Invalid: {location_name} path not provided"

    # 2) ¿Contiene espacios?
    if " " in test_location:
        return f"Invalid: {location_name} contains spaces"

    if "SD" in test_location:
        location_name = get_sd_path()

    testwrite = os.path.join(test_location, "/testwrite")
    symlink  = os.path.join(test_location, "/testwrite.link")

    try:
        # 3) Intentar crear el fichero
        with open(testwrite, "w") as f:
            pass
        if not os.path.isfile(testwrite):
            return f"Invalid: {location_name} not Writable"

        # 4) Intentar crear symlink
        try:
            os.symlink(testwrite, symlink)
        except OSError:
            return f"Invalid: {location_name} not Linkable"

        if not os.path.islink(symlink) or not os.path.isfile(symlink):
            return f"Invalid: {location_name} not Linkable"

    finally:
        # Limpieza
        for path in (symlink, testwrite):
            try:
                os.remove(path)
            except OSError as e:
                if e.errno != errno.ENOENT:
                    raise

    return "Valid"

def get_product_name() -> Optional[str]:
    """
    Lee el contenido de /sys/devices/virtual/dmi/id/product_name
    y devuelve la cadena sin saltos de línea. Si ocurre cualquier
    error (por ejemplo permisos o ausencia del fichero), devuelve None.
    """
    path = Path('/sys/devices/virtual/dmi/id/product_name')
    try:
        return path.read_text(encoding='utf-8').strip()
    except (OSError, UnicodeError):
        # Puede fallar si no existe el archivo o no tienes permisos
        return None

def get_screen_ar() -> int:
    w, h = get_primary_monitor_size()
    screen_width  = w
    screen_height = h
    if screen_height == 0:
        return 0

    # 5) Calculamos ratio con 2 decimales
    ratio_str = f"{(screen_width / screen_height):.2f}"

    # 6) Mapeamos a los códigos deseados
    if ratio_str == '1.60':
        return 1610
    elif ratio_str == '1.78':
        return 169
    else:
        return 0

def get_environment_details() -> None:
    """
    Recaba información de entorno y la imprime como JSON crudo.
    Equivalente a tu función Bash que usaba jq -r.
    """
    import json
    sd_path = get_sd_path()
    sd_valid = test_location_valid("sd", sd_path)

    first_run = not Path(emudeck_folder, ".finished").is_file()

    uname = subprocess.check_output(["uname", "-a"], text=True).strip()

    info = {
        "Home":          os.environ.get("HOME", ""),
        "Hostname":      os.environ.get("HOSTNAME", subprocess.getoutput("hostname")),
        "Username":      os.environ.get("USER", ""),
        "SDPath":        sd_path,
        "IsSDValid?":    sd_valid,
        "FirstRun?":     first_run,
        "ProductName":   get_product_name(),
        "AspectRatio":   get_screen_ar(),
        "UName":         uname,
    }

    # Imprime JSON crudo (como jq -r <<< "$json")
    print(json.dumps(info, ensure_ascii=False))

def get_primary_monitor_size():
    from screeninfo import get_monitors
    monitors = get_monitors()
    # Suponemos que el primero es el principal; o filtra por m.is_primary
    m = monitors[0]
    return m.width, m.height

def bool_from(val):
    """Convierte un valor tipo str/bool/None a booleano."""
    if isinstance(val, bool):
        return val
    if val is None:
        return False
    return str(val).lower() in ("1", "true", "yes", "y")

def set_msg(message: str):
    """
    Reproduce el comportamiento de tu función Bash set_msg:
    - Incrementa progress_bar en 5 (inicializando en 0 la primera vez).
    - Si llega a 95, lo ajusta a 90.
    - Escribe el valor de progress_bar y el mensaje en msg.log.
    - Imprime el mensaje y duerme 0.5s.
    """
    global progress_bar

    # 1) Incremento y corrección del “eterno 99%”
    progress_bar += 5
    if progress_bar == 95:
        progress_bar = 90

    # 2) Ruta al logfile
    log_path = Path(emudeck_logs) / "msg.log"
    # Asegúrate de que el directorio existe
    log_path.parent.mkdir(parents=True, exist_ok=True)

    # 3) Escribir progress y mensaje
    with log_path.open("w", encoding="utf-8") as f:
        f.write(f"{progress_bar}")
        f.write(f"# {message}\n")

    # 4) Mostrar mensaje en consola y pausar
    print(message)

def update_or_append_config_line(config_file: str, option: str, replacement: str) -> None:
    """
    - Asegura que el directorio y el fichero existen.
    - Si encuentra una línea que empiece por `option` (tras espaciado),
      la sustituye por `replacement` y muestra "updating: ...".
    - Si no la encuentra, la añade al final y muestra "appending: ...".
    """
    path = Path(config_file)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.touch(exist_ok=True)

    # Leemos todas las líneas, conservando saltos de línea
    lines = path.read_text(encoding='utf-8').splitlines(keepends=True)

    updated = False
    new_lines = []
    for line in lines:
        if line.lstrip().startswith(option):
            # Reemplazamos la línea completa sólo la primera vez
            if not updated:
                print(f"updating: {replacement} in {config_file}")
                updated = True
            new_lines.append(replacement.rstrip('\n') + '\n')
        else:
            new_lines.append(line)

    if not updated:
        print(f"appending: {replacement} to {config_file}")
        new_lines.append(replacement.rstrip('\n') + '\n')

    # Escribimos de vuelta todo el contenido
    path.write_text(''.join(new_lines), encoding='utf-8')

def ar_169_screen():
    set_msg("Applying RetroArch bezel corrections for 16:9 screens")

    root = Path(RetroArch_coreConfigFolders)
    # rglob busca todos los ficheros que casen con el patrón en subdirectorios

    # Mapea cada grupo de archivos a la lista de (option, replacement)
    config_map = {
        # pcengine.cfg
        ('pcengine.cfg',): [
            ("aspect_ratio_index =",       'aspect_ratio_index = "0"'),
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "0"'),
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.055000"'),
            ("input_overlay_x_separation_landscape =",    'input_overlay_x_separation_landscape = "0"'),
        ],
        # atari800.cfg, atari2600.cfg, atari5200.cfg
        ('atari800.cfg', 'atari2600.cfg', 'atari5200.cfg'): [
            ("aspect_ratio_index =",       'aspect_ratio_index = "0"'),
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "0"'),
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.055000"'),
            ("input_overlay_x_separation_landscape =",    'input_overlay_x_separation_landscape = "0"'),
        ],
        # ngpc.cfg, ngp.cfg
        ('ngpc.cfg', 'ngp.cfg'): [
            ("input_overlay_x_separation_portrait =",     'input_overlay_x_separation_portrait = "0"'),
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "-0.285000"'),
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.605000"'),
            ("input_overlay_y_offset_landscape =",        'input_overlay_y_offset_landscape = "-0.130000"'),
        ],
        # gb.cfg
        ('gb.cfg',): [
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.670000"'),
        ],
        # gbc.cfg
        ('gbc.cfg',): [
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.680000"'),
        ],
        # gamegear.cfg
        ('gamegear.cfg',): [
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "-0.010000"'),
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "-0.020000"'),
        ],
        # mastersystem.cfg
        ('mastersystem.cfg',): [
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.055000"'),
        ],
        # genesis.cfg, megadrive.cfg
        ('genesis.cfg', 'megadrive.cfg'): [
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.055000"'),
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "-0.010000"'),
        ],
        # megacd.cfg, segacd.cfg
        ('megacd.cfg', 'segacd.cfg'): [
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.055000"'),
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "0.000000"'),
        ],
        # sega32x.cfg
        ('sega32x.cfg',): [
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.070000"'),
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "-0.010000"'),
        ],
        # snes.cfg
        ('snes.cfg',): [
            ("input_overlay_scale_landscape =",           'input_overlay_scale_landscape = "1.055000"'),
        ],
        # n64.cfg
        ('n64.cfg',): [
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "-0.025000"'),
        ],
        # dreamcast.cfg
        ('dreamcast.cfg',): [
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "0"'),
        ],
        # saturn.cfg
        ('saturn.cfg',): [
            ("input_overlay_aspect_adjust_landscape =",  'input_overlay_aspect_adjust_landscape = "0"'),
        ],
    }

    for filenames, replacements in config_map.items():
        for fname in filenames:
            for config_path in root.rglob(fname):
                for option, repl in replacements:
                    update_or_append_config_line(str(config_path), option, repl)

def get_xdg_user_dir(name: str) -> Path:
    """
    Obtiene la carpeta XDG (por ejemplo DESKTOP) usando xdg-user-dir,
    o devuelve ~/Desktop si el comando falla o no existe.
    """
    try:
        out = subprocess.check_output(
            ['xdg-user-dir', name],
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
        if out:
            return Path(out)
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    # Fallback
    return Path.home() / 'Desktop'

def command_exists(cmd: str) -> bool:
    """Devuelve True si `command -v cmd` tiene éxito."""
    return subprocess.call(['command', '-v', cmd],
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL) == 0

def remove_if_exists(path: Path):
    """Elimina un fichero o carpeta sin lanzar excepción si no existe."""
    try:
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()
    except FileNotFoundError:
        pass

def create_desktop_shortcut(dest: Path, name: str, exec_path: str, terminal: bool):
    """
    On Linux/macOS creates a .desktop file.
    On Windows creates a .lnk shortcut at `dest` (dest should end with .lnk).
    """
    system = platform.system().lower()

    if system.startswith("win"):
        import pythoncom
        try:
            from win32com.client import Dispatch
        except ImportError:
            raise RuntimeError("pywin32 is required on Windows to create shortcuts")
        pythoncom.CoInitialize()
        # Ensure .lnk extension
        if dest.suffix.lower() != ".lnk":
            dest = dest.with_suffix(".lnk")

        icons_src = Path(emudeck_backend) / "icons"
        base = name.split(" ", 1)[0]
        icon = ""
        for ext in ("ico"):
            src_file = icons_src / f"{base}.{ext}"
            if src_file.exists():
                icon = str(src_file)
                break


        # Create shortcut
        pythoncom.CoInitialize()
        shell = Dispatch('WScript.Shell')
        shortcut = shell.CreateShortCut(str(dest))
        shortcut.Targetpath = str(exec_path)
        shortcut.WorkingDirectory = str(Path(exec_path).parent)
        # If terminal=True, wrap in cmd.exe to keep window open
        if terminal:
            shortcut.Arguments = '/k'
            shortcut.Targetpath = "cmd.exe"
        shortcut.IconLocation = str(exec_path)
        shortcut.Description = name
        shortcut.save()
        print(f"Created Windows shortcut: {dest}")
        return

    if system == "linux":
        from pathlib import Path
        import shutil

        icons_dest = Path.home() / ".local" / "share" / "icons" / "emudeck"
        icons_dest.mkdir(parents=True, exist_ok=True)

        icons_src = Path(emudeck_backend) / "icons"
        base = name.split(" ", 1)[0]
        icon = ""
        for ext in ("svg", "jpg", "png"):
            src_file = icons_src / f"{base}.{ext}"
            if src_file.exists():
                dst_file = icons_dest / src_file.name
                shutil.copy2(src_file, dst_file)
                icon = str(dst_file)
                break

        desktop_entry = [
            "[Desktop Entry]",
            "Type=Application",
            f"Name={name}",
            f"Icon={icon}",
            f"Exec={exec_path}",
            f"Terminal={'true' if terminal else 'false'}",
            "Categories=Utility;"
        ]
        dest = Path(dest)
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text("\n".join(desktop_entry) + "\n", encoding='utf-8')
        dest.chmod(0o755)
        print(f"Created .desktop file: {dest}")

    if system == "darwin":
        # Remove existing file or link
        if dest.exists() or dest.is_symlink():
            dest.unlink()

        # Create the symlink
        dest.symlink_to(exec_path)

def create_desktop_icon():
    emus_folder = home/"Applications"  # Ajusta según dónde definas emusFolder
    desktop = get_xdg_user_dir('DESKTOP')

    # Si tenemos apt-get, añadimos --no-sandbox
    sandbox_flag = ' --no-sandbox' if command_exists('apt-get') else ''

    # Lista de iconos antiguos a borrar
    old_icons = [
        "EmuDeckUninstall.desktop",
        "EmuDeckCHD.desktop",
        "EmuDeck.desktop",
        "EmuDeckSD.desktop",
        "EmuDeckBinUpdate.desktop",
        "EmuDeckApp.desktop",
        "EmuDeckAppImage.desktop",
    ]
    for icon in old_icons:
        remove_if_exists(desktop / icon)

    # Creamos el nuevo EmuDeck.desktop en el Escritorio
    appimage = f"{emus_folder}/EmuDeck.AppImage{sandbox_flag}"
    create_desktop_shortcut(
        desktop / "EmuDeck.desktop",
        "EmuDeck",
        appimage,
        terminal=False
    )

    # También en ~/.local/share/applications
    applications_dir = Path.home() / ".local" / "share" / "applications"
    create_desktop_shortcut(
        applications_dir / "EmuDeck.desktop",
        "EmuDeck",
        appimage,
        terminal=False
    )

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

def md5_of(path: Path) -> Optional[str]:
    if not path.is_file():
        return None
    h = hashlib.md5()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def changeLine(KEYWORD: str, REPLACE: str, FILE: str) -> None:
    # Mostrar info de actualización
    print(f"Updating: {FILE} - {KEYWORD} to {REPLACE}")

    path = Path(FILE)
    # Leer todas las líneas conservando los saltos de línea
    lines = path.read_text(encoding='utf-8').splitlines(keepends=True)

    new_lines = []
    for line in lines:
        if line.startswith(KEYWORD):
            # Sustituir toda la línea por REPLACE (añadiendo salto)
            new_lines.append(REPLACE.rstrip('\n') + '\n')
        else:
            new_lines.append(line)

    # Escribir de nuevo en el fichero
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
    """
    Abre un diálogo de selección de directorio usando zenity y devuelve
    la ruta seleccionada, o None si se cierra o hay error.
    Equivalente a la función Bash:
      zenity --file-selection --directory --title="Select a destination for the Emulation directory."
    """
    try:
        # Llamamos a zenity y capturamos la salida
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
        # Si el usuario cancela o no existe zenity
        return None

def get_latest_release_gh(repository: str,
                          fileType: str,
                          fileNameContains: str) -> str:
    api_url = f"https://api.github.com/repos/{repository}/releases/latest"
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    resp = requests.get(api_url, headers=headers)
    resp.raise_for_status()
    data = resp.json()

    for asset in data.get("assets", []):
        name = asset.get("name", "")
        if (fileNameContains in name
                and name.endswith(fileType)):
            return asset.get("browser_download_url", "")

    # Si no hay coincidencias
    return False

def get_latest_prerelease_gh(repository: str,
                    fileType: str,
                    fileNameContains: str) -> str:
    api_url = f"https://api.github.com/repos/{repository}/releases"
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    resp = requests.get(api_url, headers=headers)
    resp.raise_for_status()
    releases = resp.json()

    for release in releases:
        for asset in release.get("assets", []):
            name = asset.get("name", "")
            if (fileNameContains in name and name.endswith(fileType)):
                return asset.get("browser_download_url", "")

    return ""

def linkToSaveFolder(emu: str, folderName: str, path: str, saves_path: str, set_msg) -> None:
    link_path = Path(saves_path) / emu / folderName
    target_path = Path(path)

    # Caso: no existe como directorio
    if not link_path.is_dir():
        # Y tampoco existe como symlink
        if not link_path.is_symlink():
            # Creación de carpeta padre
            (Path(saves_path) / emu).mkdir(parents=True, exist_ok=True)
            set_msg(f"Linking {emu} {folderName} to the Emulation/saves folder")
            # Aseguramos que el destination exista
            target_path.mkdir(parents=True, exist_ok=True)
            # Creamos (o actualizamos) el symlink
            link_path.symlink_to(target_path, target_is_directory=True)
            print(f"Linked: {link_path} → {target_path}")
    else:
        # Ya existe como directorio (o symlink a directorio)
        if not link_path.is_symlink():
            print(f"{link_path} is not a link. Please check it.")
        else:
            # Leemos el destination actual del symlink
            current_target = os.readlink(str(link_path))
            if Path(current_target) == target_path:
                print(f"{link_path} is already linked.")
                print(f"     Target: {current_target}")
            else:
                print(f"{link_path} not linked correctly, relinking.")
                link_path.unlink()
                # Recursivamente intentamos de nuevo
                linkToSaveFolder(emu, folderName, path, saves_path, set_msg)

def linkToTexturesFolder(emu: str, folderName: str, path: str, emulation_path: str, set_msg) -> None:
    """
    Crea un symlink en $emulation_path/texturepacks/emu/folderName apuntando a path.
    Corrige enlaces existentes o informa si no son válidos.
    """
    texturepacks_dir = Path(emulation_path) / "texturepacks"
    texturepacks_dir.mkdir(parents=True, exist_ok=True)

    link_path = texturepacks_dir / emu / folderName
    target_path = Path(path)

    # Si no existe como directorio
    if not link_path.is_dir():
        if not link_path.is_symlink():
            (texturepacks_dir / emu).mkdir(parents=True, exist_ok=True)
            set_msg(f"Linking {emu} {folderName} to the Emulation/texturepacks folder")
            target_path.mkdir(parents=True, exist_ok=True)
            link_path.symlink_to(target_path, target_is_directory=True)
            print(f"Linked: {link_path} → {target_path}")
    else:
        if not link_path.is_symlink():
            print(f"{link_path} is not a link. Please check it.")
        else:
            current_target = os.readlink(str(link_path))
            if Path(current_target) == target_path:
                print(f"{link_path} is already linked.")
                print(f"     Target: {current_target}")
            else:
                print(f"{link_path} not linked correctly, relinking.")
                link_path.unlink()
                linkToTexturesFolder(emu, folderName, path, emulation_path, set_msg)

def linkToStorageFolder(emu: str, folderName: str, path: str, storage_path: str, set_msg) -> None:
    """
    Crea un symlink en $storage_path/emu/folderName apuntando a path.
    Corrige enlaces existentes o informa si no son válidos.
    """
    link_path = Path(storage_path) / emu / folderName
    target_path = Path(path)

    if not link_path.is_dir():
        if not link_path.is_symlink():
            (Path(storage_path) / emu).mkdir(parents=True, exist_ok=True)
            set_msg(f"Linking {emu} {folderName} to the {storage_path} folder")
            target_path.mkdir(parents=True, exist_ok=True)
            link_path.symlink_to(target_path, target_is_directory=True)
            print(f"Linked: {link_path} → {target_path}")
    else:
        if not link_path.is_symlink():
            print(f"{link_path} is not a link. Please check it.")
        else:
            current_target = os.readlink(str(link_path))
            if Path(current_target) == target_path:
                print(f"{link_path} is already linked.")
                print(f"     Target: {current_target}")
            else:
                print(f"{link_path} not linked correctly, relinking.")
                link_path.unlink()
                linkToStorageFolder(emu, folderName, path, storage_path, set_msg)

def moveSaveFolder(emu: str, folderName: str, path: str, saves_path: str, set_msg) -> None:
    link_path = Path(saves_path) / emu / folderName
    # Obtiene destination real (resolución completa)
    try:
        linkedTarget = Path(link_path).resolve(strict=True)
    except FileNotFoundError:
        print(f"No link at {link_path} to move from.")
        return

    # Elimina el symlink
    link_path.unlink()

    # Si tras unlink no existe, creamos carpeta y movemos
    if not link_path.exists():
        link_path.mkdir(parents=True, exist_ok=True)
        if str(linkedTarget) == str(path):
            set_msg(f"Moving {emu} {folderName} to the Emulation/saves/{emu}/{folderName} folder")
            # Copiamos contenido de path a saves_path
            shutil.copytree(path, str(link_path), dirs_exist_ok=True)
            # Renombramos el original
            bak_path = Path(path + ".bak")
            shutil.move(path, bak_path)
            # Recreamos el symlink en original
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

    # Si se indica sección, buscarla
    if iniSection:
        for i, line in enumerate(lines):
            if line.strip() == section_header:
                start_idx = i
                break
        # buscar fin de sección (la próxima cabecera)
        if start_idx is not None:
            for j in range(start_idx + 1, len(lines)):
                if lines[j].lstrip().startswith("[") and lines[j].rstrip().endswith("]"):
                    end_idx = j - 1
                    break
            else:
                end_idx = len(lines) - 1

    # Función auxiliar para detectar línea de clave
    def is_key_line(line: str) -> bool:
        return line.startswith(f"{iniKey}{separator}")

    updated = False

    if iniSection and start_idx is None:
        # sección no existe: crear cabecera + clave/value
        print(f"Creating Header {section_header}")
        if len(lines) > 0 and not lines[-1].endswith("\n"):
            lines[-1] = lines[-1] + "\n"
        lines.append(f"{section_header}\n")
        print(f"Creating {section_header} key {iniKey}{separator}{iniValue}")
        lines.append(f"{iniKey}{separator}{iniValue}\n")
        updated = True
    elif iniSection and start_idx is not None:
        # sección existe
        # buscar clave dentro del bloque
        block = lines[start_idx+1:end_idx+1] if end_idx is not None else lines[start_idx+1:]
        if not any(is_key_line(l) for l in block):
            # crear clave justo después del header
            print(f"Creating {section_header} key {iniKey}{separator}{iniValue}")
            insert_pos = start_idx + 1
            lines.insert(insert_pos, f"{iniKey}{separator}{iniValue}\n")
            updated = True
        else:
            # actualizar valor
            print(f"Updating {section_header} key {iniKey}{separator}{iniValue}")
            for k in range(start_idx+1, (end_idx or len(lines)-1) + 1):
                if is_key_line(lines[k]):
                    lines[k] = f"{iniKey}{separator}{iniValue}\n"
                    updated = True
                    break
    else:
        # sin sección o sección no relevante
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

    # 1) Hallar índice de cabecera
    start_idx = None
    for i, line in enumerate(lines):
        if line.strip() == header:
            start_idx = i
            break

    if start_idx is None:
        print(f"Section {header} not found in {file}")
        return

    # 2) Hallar fin de sección (siguiente línea que comienza por '[')
    end_idx = len(lines)
    for j in range(start_idx + 1, len(lines)):
        l = lines[j]
        if l.lstrip().startswith('[') and l.rstrip().endswith(']'):
            end_idx = j
            break

    # 3) Preparar new_content como lista de líneas con saltos
    new_block = []
    for part in new_content.splitlines():
        new_block.append(part + "\n")
    # Asegurar un salto tras el bloque si no termina en línea vacía
    if not new_content.endswith("\n"):
        new_block.append("\n")

    # 4) Reconstruir contenido:
    #    - todo hasta e incluyendo la cabecera
    #    - el new_block
    #    - el resto desde end_idx en adelante
    updated = lines[: start_idx + 1] + new_block + lines[end_idx :]

    # 5) Volcar al fichero
    path.write_text(''.join(updated), encoding='utf-8')

def calculate_checksum_sha256(file: Union[str, Path]) -> Optional[str]:
    """
    Calcula el SHA256 de un fichero y devuelve el hash en minúsculas.
    Si el fichero no existe, imprime un error y devuelve None.
    """
    file = Path(file)
    if not file.is_file():
        print(f"Error: File '{file}' does not exist.")
        return None

    h = hashlib.sha256()
    with file.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def safeDownload(name: str,
                 url: str,
                 outFile: Union[str, Path],
                 showProgress: Union[bool, str, int] = False,
                 headers: Optional[dict] = None,
                 checksumSha256: Optional[str] = None) -> bool:

    outFile = Path(outFile)
    temp_file = outFile.with_suffix(outFile.suffix + '.temp')
    headers = headers or {}

    # print("safeDownload()")
    # print(f"- Name: {name}")
    # print(f"- URL: {url}")
    # print(f"- OutFile: {outFile}")
    # print(f"- ShowProgress: {showProgress}")
    # print(f"- Headers: {headers}")
    # print(f"- Expected SHA256: {checksumSha256}")

    try:
        with requests.get(url, stream=True, headers=headers, allow_redirects=True) as r:
            r.raise_for_status()
            total = r.headers.get('content-length')
            if showProgress is True:
                total = int(total)
                downloaded = 0
                #print(f"Downloading {name}:")
                with temp_file.open('wb') as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        if not chunk:
                            continue
                        f.write(chunk)
                        downloaded += len(chunk)
                        percent = downloaded * 100 // total
                        print(f"\r  {percent}% ({downloaded}/{total} bytes)", end='', flush=True)
                print()  # salto de línea al terminar
            else:
                # Sin progreso
                with temp_file.open('wb') as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
    except Exception as e:
        print(f"{name} download failed: {e}")
        if temp_file.exists():
            temp_file.unlink()
        return False

    # Comprobación de checksum
    if checksumSha256:
        actual = calculate_checksum_sha256(temp_file)
        print(f"Downloaded File Checksum: {actual}")
        print(f"Expected Checksum:       {checksumSha256}")
        if not actual or actual.lower() != checksumSha256.lower():
            print("Checksum mismatch, deleting the corrupted file.")
            temp_file.unlink(missing_ok=True)
            return False

    # Mover temp a destination final
    try:
        temp_file.replace(outFile)
        #print(f"{name} downloaded successfully to {outFile}")
        return True
    except Exception as e:
        #print(f"Error moving temp file: {e}")
        temp_file.unlink(missing_ok=True)
        return False

def addSteamInputCustomIcons():
    src = Path(emudeck_backend) / "configs" / "steam-input" / "Icons"
    dest = Path.home() / ".steam" / "steam" / "tenfoot" / "resource" / "images" / "library" / "controller" / "binding_icons"

    if not src.is_dir():
        print(f"Source icons directory not found: {src}")
        return

    # Aseguramos que la carpeta destination existe
    dest.mkdir(parents=True, exist_ok=True)

    # Copiamos todos los ficheros y subdirectorios, preservando metadata
    for item in src.rglob('*'):
        rel = item.relative_to(src)
        target = dest / rel
        if item.is_dir():
            target.mkdir(parents=True, exist_ok=True)
        else:
            shutil.copy2(item, target)
            print(f"Copied {item} → {target}")

def is_flatpak_installed(flatPakID: str) -> bool:
    try:
        # Listado de apps de usuario
        user = subprocess.run(
            ["flatpak", "--columns=app", "list", "--user"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, check=True
        ).stdout.splitlines()
        # Listado de apps del sistema
        system = subprocess.run(
            ["flatpak", "--columns=app", "list", "--system"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, check=True
        ).stdout.splitlines()
    except subprocess.CalledProcessError:
        return False

    # Comprobamos igualdad exacta en cualquiera de las dos listas
    return any(line.strip() == flatPakID for line in user + system)

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
    # Importamos rutas desde tu configuración
    from core.vars import emudeck_logs, emudeck_folder

    # 1) Determinar carpeta Desktop
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
            # Añadir todos los archivos de logs_folder (sin conservar ruta padre)
            if logs_folder.is_dir():
                for f in logs_folder.rglob('*'):
                    if f.is_file():
                        # arcname sin incluir la parte inicial de logs_folder
                        arcname = f.relative_to(logs_folder.parent)
                        zf.write(f, arcname)
            # Añadir settings_file con su nombre base
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

def addParser(custom_parser: str) -> None:
    """
    Añade un parser JSON a SRM_userConfigurations si no existe ya.
    """
    source = Path(emudeck_backend) / "configs" / "steam-rom-manager" / "userData" / "parsers" / "optional"
    parser_path = source / custom_parser

    if not parser_path.is_file():
        print(f"Parser file not found: {parser_path}")
        return

    # Cargar el parser JSON
    with parser_path.open(encoding='utf-8') as f:
        parser_cfg = json.load(f)

    parser_id = parser_cfg.get("parserId")
    print(f"Parser ID: {parser_id}")

    srm_path = Path(SRM_userConfigurations)
    # Inicializar JSON si no existe
    if not srm_path.is_file():
        srm_path.write_text("[]\n", encoding='utf-8')

    # Leer configuración actual
    with srm_path.open(encoding='utf-8') as f:
        try:
            configs = json.load(f)
            if not isinstance(configs, list):
                raise ValueError
        except Exception:
            configs = []

    # Comprobar existencia
    if any(cfg.get("parserId") == parser_id for cfg in configs):
        print(f"Parser {parser_id} already exists in configuration.")
        return

    # Añadir y ordenar
    print("adding parser")
    configs.append(parser_cfg)
    # Llamada a SRM_setEmulationFolder (si existe)
    try:
        SRM_setEmulationFolder()
    except NameError:
        print("NYI SRM_setEmulationFolder")

    configs.sort(key=lambda x: x.get("configTitle", ""))
    # Volcar de nuevo
    srm_path.write_text(json.dumps(configs, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')

def removeParser(custom_parser: str) -> None:
    """
    Elimina un parser del SRM_userConfigurations si está presente.
    """
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

    # Filtrar fuera el parser
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
    """
    Lee la primera ocurrencia de `configVar=` en `configFile` y devuelve
    el valor tras el '=' (sin espacios). Si no se encuentra, devuelve
    `configVarDefaultValue`.
    """
    path = Path(configFile)
    value = None

    if path.is_file():
        try:
            with path.open(encoding='utf-8') as f:
                for line in f:
                    if line.startswith(f"{configVar}="):
                        # Todo lo que venga tras el primer '='
                        _, rhs = line.split("=", 1)
                        value = rhs.strip()
                        break
        except Exception:
            value = None

    if value is None or value == "":
        return configVarDefaultValue
    return value

def getEmuRepo(name: str) -> str:
    """
    Dado un nombre de emulador, devuelve el repositorio GitHub correspondiente,
    o "none" si no existe mapeo.
    """
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
    """
    Consulta la API de GitHub para obtener el campo `id`
    del release más reciente de `repository` (owner/repo).
    """
    url = f"https://api.github.com/repos/{repository}/releases/latest"
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    data = resp.json()
    # Devolver el ID como cadena
    return str(data.get("id", ""))

def addProtonLaunch():
    """
    Copia proton-launch.sh y appID.py desde el backend de EmuDeck
    a `tools_path`, y da permiso de ejecución a proton-launch.sh.
    """
    # Variables asumidas definidas en core.vars o similar:
    # emudeck_backend, tools_path

    backend_tools = Path(emudeck_backend) / "tools"
    dst = Path(tools_path)

    # Archivos a copiar
    for fname in ("proton-launch.sh", "appID.py"):
        src = backend_tools / fname
        if not src.is_file():
            print(f"Source not found: {src}")
            continue
        dst.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst / fname)
        print(f"Copied {src} → {dst / fname}")

    # Dar permiso de ejecución sólo a proton-launch.sh
    pl = dst / "proton-launch.sh"
    if pl.is_file():
        pl.chmod(pl.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        print(f"Made executable: {pl}")
    else:
        print(f"File not found for chmod: {pl}")

def store_patreon_token(token: str) -> None:
    """
    Guarda el token en saves_path/.token y lo sube mediante cloud_sync_bin si está disponible.
    """
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

def server_install() -> None:
    """
    Copia server.sh desde el backend a tools_path y le da permiso de ejecución.
    """
    src = Path(emudeck_backend) / "tools" / "server.sh"
    dst = Path(tools_path) / "server.sh"
    if not src.is_file():
        print(f"Source not found: {src}")
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)
    dst.chmod(dst.stat().st_mode | stat.S_IXUSR)
    print(f"Installed server script to {dst}")

def startCompressor() -> None:
    """
    Abre Konsole y ejecuta el script chddeck.sh en una nueva pestaña/ventana.
    """
    script = Path(emudeck_backend) / "tools" / "chdconv" / "chddeck.sh"
    if not script.is_file():
        print(f"Compressor script not found: {script}")
        return
    cmd = ["konsole", "-e", "/bin/bash", str(script)]
    subprocess.Popen(cmd)
    print(f"Started compressor via: {' '.join(cmd)}")

def call_func(func: Callable[..., Any],
              *args,
              silent: bool = True,
              **kwargs) -> Union[Any, dict]:
    """
    Ejecuta func(*args, **kwargs).
    - Si silent=False: devuelve directamente el retorno de func.
    - Si silent=True: captura stdout/stderr de func y devuelve un dict:
         {"status":"OK","result":<func_return>}
      o bien {"status":"KO","error":<mensaje>} si lanza excepción
      o {"status":"KO"} si devuelve False.
    **No** imprime nada.
    """
    if not silent:
        return func(*args, **kwargs)

    buf_out = io.StringIO()
    buf_err = io.StringIO()
    try:
        with redirect_stdout(buf_out), redirect_stderr(buf_err):
            result = func(*args, **kwargs)
    except Exception as e:
        return {"status": "KO", "error": str(e)}

    # Si la función devolvió False/None ⇒ KO
    if result is False:
        return {"status": "KO"}

    return {"status": "OK", "result": result}

def create_symlink_crossplatform(source: Path, link_path: Path):
    """
    Crea un symlink en macOS/Linux o una junction en Windows (si es un directorio).
    Si el symlink ya existe, se reemplaza.
    """
    if link_path.exists() or link_path.is_symlink():
        link_path.unlink()

    system = platform.system().lower()

    try:
        if system.startswith("win"):
            subprocess.run(
                ["cmd", "/c", "mklink", "/J", str(link_path), str(source)],
                shell=True, check=True
            )
        else:
            # Usar ln -s en macOS/Linux para evitar alias
            subprocess.run(['ln', '-sf', str(source), str(link_path)], check=True)

    except subprocess.CalledProcessError as e:
        print(f"Error creating link: {e}")
        raise

def install_emu(name, url, type_, destination):
    if destination is None:
        destination = emus_folder
    destination = Path(destination)
    # Define the folder where emulators will be stored
    emus_folder.mkdir(parents=True, exist_ok=True)

    # Temporary directory to download the file
    temp_dir = Path(tempfile.mkdtemp())
    archive_path = temp_dir / f"{name}.{type_}"
    dest_file = destination / f"{name}"

    try:
        headers = {
            "User-Agent": (
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/114.0.0.0 Safari/537.36"
            ),
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        }
        # Download the file
        response = requests.get(url, stream=True, headers=headers, timeout=30)
        response.raise_for_status()
        with open(archive_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)

        # === Handle based on file type ===
        if type_ == "exe":
            print(archive_path)
            print(dest_file)
            shutil.move(str(archive_path), str(f"{dest_file}.exe"))
            print(f"{name}.exe installedd at {dest_file}")

        if type_ == "flatpak":
            subprocess.run(["flatpak", "install", name, "-y", "--user"])
            print(f"Installed Flatpak")
            print(f"{name} flatpak installed")

        if type_ == "AppImage":
            dest_file = dest_file / ".AppImage"
            shutil.move(str(archive_path), str(dest_file / ".AppImage"))
            dest_file.chmod(0o755)
            print(f"{name}.AppImage installed at {dest_file}")

        if type_ == "tar.gz":
            extract_to = emus_folder / destination / name
            extract_to.mkdir(parents=True, exist_ok=True)
            extract_tar_gz(archive_path, extract_to)
            print(f"{name} extracted to {extract_to}")


            if system == "linux":
                # 2. Find the first .AppImage under extract_to
                appimages = list(extract_to.rglob("*.AppImage"))
                if not appimages:
                    print(f"No .AppImage found inside {extract_to}")
                    return False

                appimage_path = appimages[0]
                print(f"Found AppImage: {appimage_path}")

                # 3. Copy it to emus_folder root
                dest_file = emus_folder / appimage_path.name
                shutil.copy2(appimage_path, dest_file)
                dest_file.chmod(0o755)
                print(f"{name}.AppImage installed at {dest_file}")

            if system == "darwin":
                # 2. Find the first .AppImage under extract_to
                apps = list(extract_to.rglob("*.app"))
                if not apps:
                    print(f"No .app found inside {extract_to}")
                    return False

                app_path = apps[0]
                print(f"Found App: {app_path}")

                # 3. Copy it to emus_folder root
                dest_file = emus_folder / f"{name}.app"
                shutil.copytree(app_path, dest_file, dirs_exist_ok=True)
                dest_file.chmod(0o755)
                darwin_trust_app(dest_file)
                print(f"{name}.app installed at {dest_file}")

            # 4. (optional) clean up extracted folder
            shutil.rmtree(extract_to, ignore_errors=True)
        if type_ in ("tar.xz"):
            # Define extraction destination
            extract_to = emus_folder / destination
            extract_to.mkdir(parents=True, exist_ok=True)
            extract_tar_xz(archive_path, extract_to)
            print(f"{name} extracted to {extract_to}")

        if type_ in ("zip"):
            # Define extraction destination
            extract_to = emus_folder / destination if destination else emus_folder / name
            extract_to.mkdir(parents=True, exist_ok=True)

            if system == "linux":
                # 2. Find the first .AppImage under extract_to
                appimages = list(extract_to.rglob("*.AppImage"))
                if not appimages:
                    print(f"No .AppImage found inside {extract_to}")
                    return False

                appimage_path = appimages[0]
                print(f"Found AppImage: {appimage_path}")

                # 3. Copy it to emus_folder root
                dest_file = emus_folder / appimage_path.name
                shutil.copy2(appimage_path, dest_file)
                dest_file.chmod(0o755)
                print(f"{name}.AppImage installed at {dest_file}")
                return

            if system == "darwin":
                extract_to = emus_folder
                extract_to.mkdir(parents=True, exist_ok=True)
                with zipfile.ZipFile(archive_path, 'r') as zf:
                    zf.extractall(path=extract_to)
                return

            try:
                extract_flat(archive_path, extract_to)
            except Exception as e:
                extract(archive_path, extract_to)

            print(f"{name} extracted to {extract_to}")


        if type_ in ("7z"):
            # Define extraction destination
            extract_to = emus_folder / destination if destination else emus_folder / name
            extract_to.mkdir(parents=True, exist_ok=True)

            extract7z_flat(archive_path, extract_to)

            print(f"{name} extracted to {extract_to}")


        if type_ == "dmg":
            # 2) Use Finder/Open to mount (this invokes the GUI EULA)
            print(f"Opening {archive_path} in Finder…")
            install_dmg(name,archive_path)

        else:
            print(f"Unsupported type or platform: {type_}")
            return False

        create_app_shortcut(name)
        return True

    except Exception as e:
        print(f"Error downloading or processing {url}: {e}")
        return False

    finally:
        # Clean up temporary directory
        shutil.rmtree(temp_dir, ignore_errors=True)

def uninstall_emu(name, type_):
    if type_ == "app":
        app = Path(emus_folder / f"{name}.app" )
        app_link = Path(f"/Applications/EmuDeck/{name}.app")
        if app.exists():
            shutil.rmtree(app, ignore_errors=True)
            print(f"Removed App at {app}")
        if app_link.exists():
            shutil.rmtree(app_link, ignore_errors=True)
            print(f"Removed Link at {app_link}")

    if type_ == "AppImage":
        appimage = Path(emus_folder) /  f"{name}.AppImage"
        appimage_link = Path.home() / ".local" / "share" / "applications" / f"{name}.desktop"
        print(appimage)
        if appimage.exists():
            appimage.unlink()
            print(f"Removed AppImage at {appimage}")
        if appimage_link.exists():
            appimage_link.unlink()
            print(f"Removed AppImage Link at {appimage_link}")

    if type_ == "dir":
        dir = Path(emus_folder / name)
        if dir.exists():
            shutil.rmtree(dir, ignore_errors=True)
            print(f"Removed directory at {dir}")

    if type_ == "flatpak":
        subprocess.run(["flatpak", "uninstall", name, "-y", "--user"])
        print(f"Removed Flatpak")

def create_app_shortcut(name: str):

    launcher_name = name

    if(name == "Dolphin"):
         launcher_name = "dolphin-emu"
    if(name == "xemu"):
         launcher_name = "xemu-emu"
    if(name == "pcsx2"):
         launcher_name = "pcsx2-qt"

    if system.startswith("win"):
        import pythoncom
        appdata = Path(os.environ["APPDATA"])
        programs = appdata / "Microsoft" / "Windows" / "Start Menu" / "Programs"
        emudeck_folder_start_menu = programs / "EmuDeck"
        emudeck_folder_start_menu.mkdir(parents=True, exist_ok=True)
        dest = emudeck_folder_start_menu / name.lower()

        try:
            from win32com.client import Dispatch
        except ImportError:
            raise RuntimeError("pywin32 is required on Windows to create shortcuts")

        # Ensure .lnk extension
        if dest.suffix.lower() != ".lnk":
            dest = dest.with_suffix(".lnk")

        # Find icon
        icons_src = Path(emudeck_backend) / "icons/ico"
        base = name.split(" ", 1)[0]
        icon = ""
        ico_file = icons_src / f"{base}.ico"
        if ico_file.exists():
            icon = str(ico_file)

        # Script to run
        folder = "es-de" if name == "ES-DE" else ""

        if system.startswith("win"):
            folder = "esde" if name == "ES-DE" else ""
            name = "EmulationStationDE"

        src_file = Path(emudeck_backend) / "tools" / "launchers" / "windows" / folder / f"{launcher_name.lower()}.bat"
        script_path = Path(tools_path) / "launchers" / folder / f"{launcher_name.lower()}.bat"

        shutil.copy2(src_file, script_path)
        # Create the shortcut
        pythoncom.CoInitialize()
        shell = Dispatch('WScript.Shell')
        shortcut = shell.CreateShortCut(str(dest))

        # Point the .lnk at PowerShell and pass your .ps1 as an argument
        ps_exe = Path(os.environ["WINDIR"]) / "System32" / "WindowsPowerShell" / "v1.0" / "powershell.exe"
        shortcut.Targetpath = str(ps_exe)
        # Bypass execution policy and run your script
        shortcut.Arguments = f'-NoProfile -ExecutionPolicy Bypass -File "{script_path}"'
        shortcut.WorkingDirectory = str(script_path.parent)
        if icon:
            shortcut.IconLocation = icon
        shortcut.Description = name
        shortcut.save()

        print(f"Created Windows shortcut: {dest}")
        return

    if system == "linux":

        icons_src = Path(emudeck_backend) / "icons"
        icons_dest = Path.home() / ".local" / "share" / "icons" / "emudeck"
        icons_dest.mkdir(parents=True, exist_ok=True)

        base = name.split(" ", 1)[0]
        icon = ""
        for ext in ("svg", "jpg", "png"):
            src_file = icons_src / f"{base}.{ext}"
            if src_file.exists():
                dst_file = icons_dest / src_file.name
                shutil.copy2(src_file, dst_file)
                icon = str(dst_file)
                break

        folder=""
        if name == "ES-DE":
            folder="es-de"

        src_file = Path(emudeck_backend) / "tools" / "launchers" / "unix" / folder / f"{launcher_name.lower()}.sh"
        exec_path = Path(tools_path) / "launchers" / folder / f"{launcher_name.lower()}.sh"

        shutil.copy2(src_file, exec_path)

        desktop_entry = [
            "[Desktop Entry]",
            "Type=Application",
            f"Name={name} - EmuDeck",
            f"Icon={icon}",
            f"Exec={exec_path}",
            f"Terminal=false",
            "Categories=Utility;"
        ]

        applications_dir = Path.home() / ".local" / "share" / "applications"
        dest = applications_dir / f"{name}.desktop"
        dest = Path(dest)
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text("\n".join(desktop_entry) + "\n", encoding='utf-8')
        dest.chmod(0o755)
        print(f"Created .desktop file: {dest}")

    if system == "darwin":
        folder=""
        if name == "ES-DE":
            folder="es-de"
        src_file = Path(emudeck_backend) / "tools" / "launchers" / "unix" / folder / f"{launcher_name.lower()}.sh"
        exec_path = Path(tools_path) / "launchers" / folder / f"{launcher_name.lower()}.sh"
        shutil.copy2(src_file, exec_path)

        create_mac_app(name, Path(exec_path))

def create_mac_app(app_name: str, script_path: Path, output_dir: Path = Path("/Applications/EmuDeck")):

    # Define bundle structure
    app_bundle = output_dir / f"{app_name}.app"
    contents_dir = app_bundle / "Contents"
    macos_dir = contents_dir / "MacOS"
    resources_dir = contents_dir / "Resources"

    # Create necessary directories
    macos_dir.mkdir(parents=True, exist_ok=True)
    resources_dir.mkdir(parents=True, exist_ok=True)

    # Copy the shell script into Contents/MacOS and make it executable
    exec_name = script_path.stem  # e.g. "myscript"
    target_exec = macos_dir / exec_name
    shutil.copy2(script_path, target_exec)
    target_exec.chmod(target_exec.stat().st_mode | stat.S_IEXEC)

    # Create Info.plist
    plist = {
        "CFBundleName": app_name,
        "CFBundleDisplayName": app_name,
        "CFBundleIdentifier": f"com.local.{app_name.lower()}",
        "CFBundleVersion": "1.0",
        "CFBundlePackageType": "APPL",
        "CFBundleExecutable": exec_name,
        "CFBundleInfoDictionaryVersion": "6.0"
    }
    with open(contents_dir / "Info.plist", "wb") as f:
        plistlib.dump(plist, f)

    print(f"✅ Created macOS app bundle at: {app_bundle}")

def extract(zip_path: Path, extract_to: Path) -> None:
    """
    Extract a ZIP archive preserving its full directory structure.
    """
    extract_to.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(zip_path, 'r') as zf:
        zf.extractall(path=extract_to)

def extract_flat(zip_path: Path, extract_to: Path):
    """
    Extract a ZIP archive, ignoring a single top-level directory if present.
    Files end up directly under extract_to.
    """
    with zipfile.ZipFile(zip_path, 'r') as zf:
        # Gather all file entries (skip pure directories)
        files = [name for name in zf.namelist() if not name.endswith('/')]
        # Determine if there’s exactly one common root folder
        roots = {Path(f).parts[0] for f in files}
        common_root = roots.pop() if len(roots) == 1 else None

        for member in zf.infolist():
            if member.is_dir():
                continue
            src = Path(member.filename)
            # Strip the common root if found
            parts = src.parts[1:] if common_root and src.parts[0] == common_root else src.parts
            dest = extract_to.joinpath(*parts)
            dest.parent.mkdir(parents=True, exist_ok=True)
            with zf.open(member) as src_file, open(dest, 'wb') as dst_file:
                shutil.copyfileobj(src_file, dst_file)

def extract7z_flat(archive_path: Path, extract_to: Path):
    """
    Extract a .7z archive, ignoring a single top-level directory if present.
    - On Windows: uses the built-in `tar.exe -xf` (available in Win11).
    - Otherwise: tries py7zr and then falls back to external `7z`.
    """
    extract_to.mkdir(parents=True, exist_ok=True)

    # WINDOWS ⏩ use native tar to handle .7z
    if sys.platform == "win32":
        cmd = [
            "tar", "-xf", str(archive_path),
            "-C", str(extract_to)
        ]
        subprocess.run(cmd, check=True)
        # After extraction, flatten a single top folder if needed:
        items = list(extract_to.iterdir())
        if len(items) == 1 and items[0].is_dir():
            top = items[0]
            for child in top.iterdir():
                child.rename(extract_to / child.name)
            top.rmdir()
        return

    # NON-Windows: try pure-Python first
    try:
        with py7zr.SevenZipFile(str(archive_path), mode='r') as zf:
            all_files = [n for n in zf.getnames() if not n.endswith('/')]
            roots = {Path(f).parts[0] for f in all_files}
            common_root = roots.pop() if len(roots) == 1 else None

            for name, bio in zf.readall().items():
                if name.endswith('/'):
                    continue
                src = Path(name)
                parts = src.parts[1:] if common_root and src.parts[0] == common_root else src.parts
                dest = extract_to.joinpath(*parts)
                dest.parent.mkdir(parents=True, exist_ok=True)
                with open(dest, 'wb') as f:
                    f.write(bio.read())
        return

    except Exception as e:
        # If it's not BCJ2, re-raise
        if "BCJ2 filter is not supported" not in str(e):
            raise

    # FALLBACK on Unix-like: external 7z CLI
    cmd = [
        "7z", "x",               # extract
        "-y",                    # yes to all
        f"-o{extract_to}",       # output dir
        str(archive_path)
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

    # flatten top-level if needed
    items = list(extract_to.iterdir())
    if len(items) == 1 and items[0].is_dir():
        top = items[0]
        for child in top.iterdir():
            child.rename(extract_to / child.name)
        top.rmdir()

def install_dmg(name, archive_path):
    subprocess.run(["open", str(archive_path)], check=True)
    # 3) Wait for mount to appear under /Volumes
    mount_point = None
    for _ in range(30):
        for vol in Path("/Volumes").iterdir():
            # match a volume whose name begins with our dmg base name
            #if vol.name.startswith(name):
            mount_point = vol
            break
        if mount_point:
            break

    if not mount_point:
        print("❌ Timeout: DMG did not mount in /Volumes.")
        return False

    print(f"✅ Mounted at {mount_point}")

    # 4) Locate the .app bundle
    apps = list(mount_point.glob("*.app"))
    if not apps:
        print("❌ No .app found inside the DMG.")
        # allow user to finish reading then detach
        input("Press Enter to unmount…")
        subprocess.run(["hdiutil", "detach", str(mount_point)])
        return False

    app_bundle = apps[0]
    target = Path.home() / "Applications" / app_bundle.name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(app_bundle, target, dirs_exist_ok=True)
    print(f"✔️  Copied {app_bundle.name} → {target}")
    darwin_trust_app(target)
    # 5) Finally unmount
    subprocess.run(["hdiutil", "detach", str(mount_point)], stdout=subprocess.DEVNULL)
    print("✔️  DMG detached.")
    return True

def extract_tar_gz(archive_path: Path, extract_to: Path):
    extract_to.mkdir(parents=True, exist_ok=True)
    with tarfile.open(archive_path, mode="r:gz") as tf:
        tf.extractall(path=extract_to)

def copy_setting_dir(src: Path, dst: Path):
    src = Path( emudeck_backend / "configs" / src)
    shutil.copytree(
        src,
        dst,
        dirs_exist_ok=True
    )
def copy_and_set_settings_file(src: Union[str, Path],
                               dst: Union[str, Path]) -> Path:
    """
    Copy a config file from:
        emudeck_backend/configs/<src>
    into the directory <dst>, preserving its filename.

    :param src: Relative path under configs, e.g. "windows/azahar/qt-config.ini"
    :param dst: Target directory (or Path) where the file should be copied.
    :returns: The Path to the newly copied file.
    :raises FileNotFoundError: if the source file doesn't exist.
    """
    # Build absolute source path
    src_path = Path(emudeck_backend) / "configs" / Path(src)
    if not src_path.is_file():
        raise FileNotFoundError(f"Source file not found: {src_path}")

    # Ensure dst_dir exists
    dst_dir = Path(dst)
    dst_dir.mkdir(parents=True, exist_ok=True)

    # Destination file is dst_dir / <same filename>
    dst_file = dst_dir / src_path.name

    # Copy (cross-drive safe) with metadata
    shutil.copy2(src_path, dst_file)

    print(f"Copied {src_path} → {dst_file}")
    sed("EMULATIONPATH",emulation_path,dst_file)
    sed("STEAMPATH",steam_install_path,dst_file)
    ext=".sh"
    if system.startswith("win"):
        ext=".bat"
    sed(".EXT",ext,dst_file)

def sed(old: str, replacement: str, file_path: str) -> None:
    replacement = str(replacement)
    file_str = str(file_path)

    pattern = re.compile(re.escape(old))
    # Escape backslashes so "\\E" becomes "\\\\E" etc.
    safe_repl = replacement.replace("\\", "\\\\")
    for line in fileinput.input(str(file_path), inplace=True, backup=".bak"):
        new_line = pattern.sub(safe_repl, line)
        print(new_line, end="")


def move_contents_and_link(origin: Union[str, Path], destination: Union[str, Path]) -> bool:
    origin = Path(origin)
    destination = Path(destination)
    print("Linking...")
    # If origin doesn't exist at all, nothing to do
    if not origin.exists():
        origin.mkdir(parents=True, exist_ok=True)
        print("Info: No origin, creating")
        #return False

    # If origin is already a symlink/junction, skip
    if origin.is_symlink():
        print("Warning: Origin is symlink")
        return False

    # Only handle directories
    if origin.is_dir():
        # Ensure destination exists
        destination.mkdir(parents=True, exist_ok=True)

        # Move each item from origin into destination
        for item in origin.iterdir():
            shutil.move(str(item), str(destination / item.name))

        # Remove the now-empty origin folder
        try:
            origin.rmdir()
        except OSError:
            # If it fails (e.g. non-empty), ignore
            pass

        # Create link: symlink on Unix, junction on Windows
        if system.startswith("win"):
            # Windows: try directory symlink first
            try:
                print("Linking folder")
                os.symlink(str(destination), str(origin), target_is_directory=True)
            except (OSError, NotImplementedError):
                # Fallback to a junction via mklink
                subprocess.run(
                    ["cmd", "/c", "mklink", "/J", str(origin), str(destination)],
                    shell=True,
                    check=True
                )
        else:
            # Unix-like: normal symlink
            os.symlink(str(destination), str(origin))

        return True

    # origin exists but is not a directory (e.g. file)
    return False

def set_config(old: str, new: str, file_to_check: Path, separator: str = "=") -> None:
    file_to_check = Path(file_to_check)
    # Read all lines (preserving newlines later)
    lines = file_to_check.read_text(encoding="utf-8").splitlines()

    # Prepare the new line
    new_line = f"{old}{separator}{new}"

    # Search for an existing line containing 'old'
    for idx, line in enumerate(lines):
        if old in line:
            old_line = line
            lines[idx] = new_line
            # Write back
            file_to_check.write_text("\n".join(lines) + "\n", encoding="utf-8")
            print(f"Line '{old_line}' changed to '{new_line}'")
            return

    # If we get here, no existing line was found—append instead
    with file_to_check.open("a", encoding="utf-8") as f:
        f.write(new_line + "\n")
    print(f"Line '{new_line}' created in {file_to_check}")

def extract_tar_xz(archive_path: Path, extract_to: Path):
    """
    Extrae un .tar.xz al directorio indicado.
    """
    # Asegúrate de que exista la carpeta destino
    extract_to.mkdir(parents=True, exist_ok=True)

    # "r:xz" abre un tar comprimido con xz
    with tarfile.open(archive_path, mode="r:xz") as tar:
        tar.extractall(path=extract_to)

def darwin_trust_app(app_path: Path):
        subprocess.run([
            "xattr", "-r", "-d", "com.apple.quarantine", str(app_path)
        ], check=False)
def get_linux_version_id() -> str:
    try:
        with open("/etc/os-release", encoding="utf-8") as f:
            for line in f:
                if line.startswith("VERSION_ID="):
                    return line.split("=",1)[1].strip().strip('"')
    except FileNotFoundError:
        pass
    return ""

def update_json_key(key: str, new_value: Any, file_path: Path) -> None:
    data = {}
    file_path = Path(file_path)
    if file_path.exists():
        with file_path.open("r", encoding="utf-8") as f:
            data = json.load(f)

    data[key] = new_value

    with file_path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write("\n")  # s


def md5_of_file(path: Path) -> str:
    """Return the lowercase MD5 checksum of a file."""
    h = hashlib.md5()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def set_setting(key: str, value: Any) -> None:
    json_path = Path(emudeck_folder) / "settings.json"
    data: dict[str, Any]
    if json_path.exists():
        try:
            with json_path.open('r', encoding='utf-8') as f:
                data = json.load(f)
                if not isinstance(data, dict):
                    data = {}
        except json.JSONDecodeError:
            data = {}
    else:
        data = {}

    # Soporte para claves anidadas
    keys = key.split('.')
    d = data
    for k in keys[:-1]:
        if k not in d or not isinstance(d[k], dict):
            d[k] = {}
        d = d[k]
    d[keys[-1]] = value

    with json_path.open('w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write("\n")
    #Settings reload
    json_settings_path = Path(emudeck_folder) / "settings.json"
    if json_settings_path.exists():
        with open(json_settings_path, encoding='utf-8') as jf:
            # Aquí json.load lee y va aplicando object_hook a cada dict
            settings = json.load(jf, object_hook=lambda d: SimpleNamespace(**d))

def popup_ask_conflict(title: str, message: str) -> Optional[bool]:
    app = ensure_app()
    dlg = BaseDialog(title)

    lbl = QtWidgets.QLabel(message)
    lbl.setWordWrap(True)
    dlg._add(lbl)

    # Botones
    btn_layout = QtWidgets.QHBoxLayout()
    yes_btn = QtWidgets.QPushButton("Yes")
    no_btn  = QtWidgets.QPushButton("No")
    ca_btn  = QtWidgets.QPushButton("Cancel")
    btn_layout.addWidget(yes_btn)
    btn_layout.addWidget(no_btn)
    btn_layout.addWidget(ca_btn)
    dlg._inner.addLayout(btn_layout)

    widgets = [yes_btn, no_btn, ca_btn]
    # initial focus on first button
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
            # if vertical layout just wrap among them:
            idx = (idx + (1 if dir=="down" else -1)) % len(widgets)
            widgets[idx].setFocus()
        gp = poll_gamepad()
        if gp in ("yes","no","cancel"):
            _set(gp)
        QtCore.QThread.msleep(50)

    return {"yes": True, "no": False, "cancel": None}.get(choice)

def popup_show_info(title: str, message: str) -> None:
    """
    OK-only dialog.
    """
    app = ensure_app()
    dlg = BaseDialog(title)

    lbl = QtWidgets.QLabel(message)
    lbl.setWordWrap(True)
    dlg._add(lbl)

    ok = QtWidgets.QPushButton("OK")
    ok.clicked.connect(dlg.accept)
    dlg._add(ok, alignment=QtCore.Qt.AlignCenter)

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        if poll_gamepad() in ("yes","no","cancel"):
            dlg.accept()
        QtCore.QThread.msleep(50)

def popup_ask_string(prompt: str, title: str = "Input") -> Optional[str]:
    """
    Text input dialog. None si se cancela o vacía.
    """
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
    """
    Password dialog (input oculto).
    """
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

    # — Network drives (DriveType = 4) —
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

    # — Physical disks —
    for disk in c.Win32_DiskDrive():
        media = disk.MediaType or ""
        if "Fixed hard disk media" in media:
            dtype = "Internal"
        elif "Removable media" in media:
            dtype = "External"
        else:
            dtype = "Unknown"

        # Para cada partición asociada
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

    # Ordenar por letra
    drive_info.sort(key=lambda d: d["letter"])

    # Fallback si no hay nada
    if not drive_info:
        drive_info = [{
            "type":   "Internal",
            "letter": "C:",
            "name":   "harddisk SSD",
            "size":   999
        }]

    return drive_info

def add_parser(
        custom_parser: str,
    ) -> bool:
    source_dir = (
        emudeck_backend
        / "configs"
        / "steam-rom-manager"
        / "userData"
        / "parsers"
        / "optional"
    )

    srm_user_configurations = f"{srm_path}/userData/userConfigurations.json"

    parser_path = source_dir / f"{custom_parser}.json"
    if not parser_path.is_file():
        return False

    # Leer el nuevo parser
    new_cfg = json.loads(parser_path.read_text(encoding="utf-8"))
    parser_id = new_cfg.get("parserId")
    print(f"Parser ID: {parser_id}")

    # Asegurar que existe el fichero de configuraciones
    if not srm_user_configurations.exists():
        srm_user_configurations.write_text("[]", encoding="utf-8")

    # Cargar lista actual
    configs = json.loads(srm_user_configurations.read_text(encoding="utf-8"))

    # ¿Ya existe ese parserId?
    if any(item.get("parserId") == parser_id for item in configs):
        return True  # nada que hacer

    # Añadir y ordenar
    print("adding parser")
    configs.append(new_cfg)
    # Llamada a tu función de Python equivalente a SRM_setEmulationFolder

    configs.sort(key=lambda x: x.get("configTitle", ""))

    # Guardar de nuevo
    srm_user_configurations.write_text(
        json.dumps(configs, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return True


def load_remote_module(url: str, module_name: str):
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
    source = resp.text

    spec = importlib.util.spec_from_loader(module_name, loader=None)
    module = importlib.util.module_from_spec(spec)
    exec(source, module.__dict__)
    sys.modules[module_name] = module
    return module

def load_remote_cloud_sync():
    REMOTE_URL = f"https://token.emudeck.com/cloud-check.php?access_token={settings.patreonToken}"
    try:
       cloudsync_remote = load_remote_module(REMOTE_URL, "cloudsync_remote")
    except Exception as e:
       cloudsync_remote = None

    return cloudsync_remote

def netplay_set_ip() -> Optional[str]:
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            # doesn't send, just picks the correct outbound interface
            s.connect(("8.8.8.8", 80))
            local_ip = s.getsockname()[0]
    except Exception:
        return None

    # 2) Build the first three octets
    octets = local_ip.split(".")
    if len(octets) != 4:
        return None
    segment = ".".join(octets[:3]) + "."

    port = 55435
    for i in range(2, 256):
        ip = f"{segment}{i}"
        try:
            # 3) Attempt a TCP connect with 50 ms timeout
            with socket.create_connection((ip, port), timeout=0.05):
                # 4) Success! Persist and return.
                set_setting("netplay_cmd", f"'-C {ip}'")
                return ip
        except (socket.timeout, ConnectionRefusedError, OSError):
            continue

    return None


def calculate_md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def calculate_md5_without_header(
        file: Union[str, Path],
        header_size: int,
        chunk_size: int = 8192
    ) -> str:
        """
        Compute the MD5 checksum of the file at `file`, skipping the first
        `header_size` bytes.

        :param file: Path to the file.
        :param header_size: Number of bytes to skip at the start.
        :param chunk_size: Read in chunks of this size.
        :returns: Hexadecimal MD5 digest string.
        """
        file_path = Path(file)
        md5 = hashlib.md5()
        with file_path.open('rb') as f:
            # skip header
            f.seek(header_size)
            # read the rest in chunks
            for chunk in iter(lambda: f.read(chunk_size), b''):
                md5.update(chunk)
        return md5.hexdigest()