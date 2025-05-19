from core.all import *

def generate_preliminary_id(exe, appname):
    """
    Genera un ID preliminar utilizando CRC32 y el bit más significativo.
    Equivalente a `generatePreliminaryId` en SRM.
    """
    key = exe + appname
    crc_value = zlib.crc32(key.encode('utf-8')) & 0xFFFFFFFF  # Aseguramos 32 bits
    top = (crc_value | 0x80000000)  # Establecer el bit más significativo
    return (top << 32) | 0x02000000  # Combinar con 0x02000000

def generate_app_id(exe, appname):
    """
    Genera el AppId completo utilizado en Big Picture Grids.
    Equivalente a `generateAppId` en SRM.
    """
    return str(generate_preliminary_id(exe, appname))

def generate_short_app_id(exe, appname):
    """
    Genera el ShortAppId utilizado para otras grids.
    Equivalente a `generateShortAppId` en SRM.
    """
    long_id = generate_preliminary_id(exe, appname)
    return str(long_id >> 32)

def generate_shortcut_id(exe, appname):
    """
    Genera el ShortcutId utilizado en shortcuts.vdf.
    Equivalente a `generateShortcutId` en SRM.
    """
    long_id = generate_preliminary_id(exe, appname)
    return int((long_id >> 32) - 0x100000000)

def shorten_app_id(long_id):
    """
    Convierte un AppId largo a un ShortAppId.
    Equivalente a `shortenAppId` en SRM.
    """
    return str(int(long_id) >> 32)

def lengthen_app_id(short_id):
    """
    Convierte un ShortAppId a un AppId largo.
    Equivalente a `lengthenAppId` en SRM.
    """
    return str((int(short_id) << 32) | 0x02000000)

def shortcutify_app_id(long_id):
    """
    Convierte un AppId largo a un ShortcutAppId.
    Equivalente a `shortcutifyAppId` en SRM.
    """
    return int(shorten_app_id(long_id)) >> 32

def appify_shortcut_id(shortcut_id):
    """
    Convierte un ShortcutAppId a un AppId largo.
    Equivalente a `appifyShortcutId` en SRM.
    """
    return lengthen_app_id(str(int(shortcut_id) + 0x100000000))



def copy_steam_images(grid_path, id, shortcut_id):
    # Directorio de las imágenes de Steam ROM Manager
    if os.name == 'nt':
        src_dir = os.path.expanduser(f"~/AppData/Roaming/EmuDeck/backend/configs/common/srm/userData/img/emus/{id}")
    else:
        src_dir = os.path.expanduser(f"~/.config/EmuDeck/backend/configs/common/srm/userData/img/emus/{id}")


    # Definir las rutas de origen y destino
    images = {
        "hero": (f"{src_dir}/{id}_hero.png", f"{grid_path}/{shortcut_id}_hero.jpg"),
        "logo": (f"{src_dir}/{id}_logo.png", f"{grid_path}/{shortcut_id}_logo.png"),
        "banner": (f"{src_dir}/{id}_banner.png", f"{grid_path}/{shortcut_id}.jpg"),
        "portrait": (f"{src_dir}/{id}_portrait.png", f"{grid_path}/{shortcut_id}p.png"),
        "icon": (f"{src_dir}/{id}_ico.png", f"{grid_path}/{shortcut_id}_icon.ico"),
    }

    # Copiar cada imagen si existe
    for img_type, (src, dst) in images.items():
        if os.path.exists(src):
            shutil.copy(src, dst)
            print(f"{img_type.capitalize()} image copied: {dst}")
        else:
            print(f"{img_type.capitalize()} image not found: {src}")


def add_steam_shortcut(id, name, target_path, start_dir, icon_path):
    if system in ("linux", "darwin"):
        # 1) Locate Steam directory
        steam_dir = home / ".steam" / "steam"
        if system == "darwin":
            steam_dir = home / "Library" / "Application Support" / "Steam"

    # 2) Find most‐recent userdata ID
    if system.startswith("win"):
        steam_install_path, steam_install_path_srm, steam_exe = get_steam_paths()
        steam_dir = Path(steam_install_path)
    exe_path = target_path
    userdata = steam_dir / "userdata"
    user_id = ""
    if userdata.is_dir():
        subs = [d for d in userdata.iterdir() if d.is_dir()]
        if subs:
            user_id = max(subs, key=lambda d: d.stat().st_mtime).name
    # Kill Steam
    if system == "darwin":
        try:
            output = subprocess.check_output(
                ["ps", "aux"],
                text=True
            )
            for line in output.splitlines():
                if "steam" in line and "grep" not in line:
                    parts = line.split()
                    pid = parts[1]
                    subprocess.run(["kill", "-9", pid], check=False)
                    print(f"Sent SIGTERM to Steam (pid {pid})")
        except Exception:
            pass
    if system == "linux":
        subprocess.run(["kill", "-15", subprocess.check_output(["pidof", "steam"], text=True).strip()],
                    check=False)
    if system.startswith("win"):
        subprocess.run(["taskkill", "/IM", "steam.exe", "/F"], check=False)

        windir = os.environ.get("WINDIR", r"C:\Windows")
        cmd_exe = Path(windir) / "System32" / "cmd.exe"
        ps_exe  = Path(windir) / "System32" / "WindowsPowerShell" / "v1.0" / "powershell.exe"
        launcher_cmd = (
            f'"{cmd_exe}" /k start /min "Loading PowerShell Launcher" '
            f'"{ps_exe}" -NoProfile -ExecutionPolicy Bypass -File "{target_path}" && exit && exit --emudeck'
        )
        exe_path = launcher_cmd

    # Ruta del archivo shortcuts.vdf
    shortcuts_path = os.path.join(steam_dir,'userdata',user_id, "config", "shortcuts.vdf")

    grid_path = os.path.join(steam_dir,'userdata',user_id, "config", "grid")

    # Leer el archivo actual
    try:
        with open(shortcuts_path, "rb") as f:
            shortcuts_data = vdf.binary_load(f)
    except FileNotFoundError:
        # Crear una estructura básica si no existe el archivo
        shortcuts_data = {"shortcuts": {}}

    # Normalizar el nombre y la ruta para evitar duplicados por mayúsculas o espacios
    normalized_name = name.strip().lower()
    normalized_target = target_path.strip().lower()

    # Comprobar si ya existe un acceso directo con el mismo nombre o ruta
    for shortcut in shortcuts_data.get("shortcuts", {}).values():
        existing_name = shortcut.get("appname", "").strip().lower()
        existing_target = shortcut.get("exe", "").strip('"').strip().lower()

        if existing_name == normalized_name or existing_target == normalized_target:
            print(f"El acceso directo '{name}' ya existe en Steam y no se añadirá.")
            return  # Salir sin añadir el acceso directo

    # Buscar el próximo índice disponible
    existing_indices = [int(k) for k in shortcuts_data["shortcuts"].keys()]
    next_index = max(existing_indices, default=-1) + 1

    # Generar un AppID válido
    appid = generate_short_app_id(target_path, name)

    # Crear el nuevo acceso directo
    shortcuts_data["shortcuts"][str(next_index)] = {
        "appname": name,
        "exe": f'"{exe_path}"',
        "StartDir": f'"{start_dir}"',
        "icon": f'"{icon_path}"',
        "ShortcutPath": "",
        "LaunchOptions": "",
        "IsHidden": 0,
        "AllowDesktopConfig": 1,
        "AllowOverlay": 1,
        "OpenVR": 0,
        "Devkit": 0,
        "DevkitGameID": "",
        "LastPlayTime": 0,
        "tags": {"0": "favorite"},
        "appid": appid  # Agregar el AppID
    }

    # Escribir los cambios de vuelta al archivo
    with open(shortcuts_path, "wb") as f:
        vdf.binary_dump(shortcuts_data, f)

    print(f"El acceso directo '{name}' se ha añadido correctamente con AppID {appid} en '{shortcuts_path}'")

    # Crear el directorio para las imágenes si no existe
    os.makedirs(grid_path, exist_ok=True)

    # Copiar imágenes usando el AppID
    copy_steam_images(grid_path, id, appid)

    subprocess.Popen([steam_exe, "-silent"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

