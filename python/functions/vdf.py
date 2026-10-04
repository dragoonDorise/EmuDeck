from core.all import *
import base64
import urllib.request

def generate_preliminary_id(exe, appname):
    key = exe + appname
    crc_value = zlib.crc32(key.encode('utf-8')) & 0xFFFFFFFF  # Aseguramos 32 bits
    top = (crc_value | 0x80000000)  # Establecer el bit más significativo
    return (top << 32) | 0x02000000  # Combinar con 0x02000000

def generate_app_id(exe, appname):
    return str(generate_preliminary_id(exe, appname))

def generate_short_app_id(exe, appname):
    long_id = generate_preliminary_id(exe, appname)
    return str(long_id >> 32)

def generate_shortcut_id(exe, appname):
    long_id = generate_preliminary_id(exe, appname)
    return int((long_id >> 32) - 0x100000000)

def shorten_app_id(long_id):
    return str(int(long_id) >> 32)

def lengthen_app_id(short_id):
    return str((int(short_id) << 32) | 0x02000000)

def shortcutify_app_id(long_id):
    return int(shorten_app_id(long_id)) >> 32

def appify_shortcut_id(shortcut_id):
    return lengthen_app_id(str(int(shortcut_id) + 0x100000000))



ARTWORK_BASE_URL = os.environ.get("EMUDECK_ARTWORK_URL", "https://cdn.jsdelivr.net/gh/EmuDeck/emulator-artwork@main")


def artwork_cache_dir():
    if os.name == 'nt':
        return os.path.join(os.environ.get("APPDATA", os.path.expanduser("~")), "EmuDeck", "artwork")
    return os.path.expanduser("~/.config/EmuDeck/artwork")


def fetch_artwork(id, kind):
    cache_dir = os.path.join(artwork_cache_dir(), id)
    os.makedirs(cache_dir, exist_ok=True)
    path = os.path.join(cache_dir, f"{id}_{kind}.png")
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return path
    url = f"{ARTWORK_BASE_URL}/{id}/{id}_{kind}.png"
    try:
        request = urllib.request.Request(url, headers={"User-Agent": "EmuDeck"})
        with urllib.request.urlopen(request, timeout=15) as response:
            data = response.read()
        if data:
            with open(path, "wb") as f:
                f.write(data)
            return path
    except Exception as error:
        print(f"Artwork download failed for {id} {kind}: {error}")
    return None


def copy_steam_images(grid_path, id, shortcut_id):
    images = {
        "hero": ("hero", f"{grid_path}/{shortcut_id}_hero.jpg"),
        "logo": ("logo", f"{grid_path}/{shortcut_id}_logo.png"),
        "banner": ("banner", f"{grid_path}/{shortcut_id}.jpg"),
        "portrait": ("portrait", f"{grid_path}/{shortcut_id}p.png"),
        "icon": ("ico", f"{grid_path}/{shortcut_id}_icon.ico"),
    }

    for img_type, (kind, dst) in images.items():
        src = fetch_artwork(id, kind)
        if src:
            shutil.copy(src, dst)
            print(f"{img_type.capitalize()} image copied: {dst}")
        else:
            print(f"{img_type.capitalize()} image not available for {id}")


def build_tags(collection):
    tags = {"0": "favorite"}
    if collection:
        tags["1"] = collection
    return tags


def add_tag(shortcut, collection):
    if not collection:
        return False
    tags = shortcut.get("tags") or {}
    if collection in tags.values():
        return False
    next_key = max([int(k) for k in tags.keys()], default=-1) + 1
    tags[str(next_key)] = collection
    shortcut["tags"] = tags
    return True


def to_unsigned_app_id(value):
    try:
        return int(value) & 0xFFFFFFFF
    except (TypeError, ValueError):
        return None


def add_to_collection(user_dir, collection, app_id):
    if not collection or app_id is None:
        return
    cloud_dir = os.path.join(user_dir, "config", "cloudstorage")
    namespaces_path = os.path.join(cloud_dir, "cloud-storage-namespaces.json")
    namespace = 1
    if os.path.exists(namespaces_path):
        try:
            with open(namespaces_path, "r", encoding="utf-8") as f:
                entries = sorted(json.load(f), key=lambda e: int(e[1]), reverse=True)
            if entries and entries[0][1] != "0":
                namespace = entries[0][0]
        except (ValueError, IndexError, TypeError, OSError):
            pass
    storage_path = os.path.join(cloud_dir, f"cloud-storage-namespace-{namespace}.json")
    if not os.path.exists(storage_path):
        print(f"Cloud storage no encontrado, colección '{collection}' no añadida: {storage_path}")
        return
    with open(storage_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    index = None
    key = None
    for i, item in enumerate(data):
        if not item or not str(item[0]).startswith("user-collections.") or item[1].get("is_deleted"):
            continue
        try:
            existing = json.loads(item[1]["value"])
        except (KeyError, ValueError):
            continue
        if str(existing.get("name", "")).upper() == collection.upper():
            index, key = i, item[0]
            break

    if key is None:
        encoded = base64.urlsafe_b64encode(collection.encode("utf-8")).decode("ascii").rstrip("=")
        key = f"user-collections.emudeck-{encoded}"
        existing = {"id": key[len("user-collections."):], "name": collection, "added": [], "removed": []}

    existing.setdefault("added", [])
    existing.setdefault("removed", [])
    if app_id in existing["added"] and app_id not in existing["removed"]:
        return
    if app_id not in existing["added"]:
        existing["added"].append(app_id)
    if app_id in existing["removed"]:
        existing["removed"].remove(app_id)

    timestamp = int(time.time())
    entry = [key, {
        "key": key,
        "timestamp": timestamp,
        "value": json.dumps(existing, separators=(",", ":")),
        "version": str(timestamp),
        "conflictResolutionMethod": "custom",
        "strMethodId": "union-collections",
    }]
    if index is None:
        data.append(entry)
    else:
        data[index] = entry
    with open(storage_path, "w", encoding="utf-8") as f:
        json.dump(data, f, separators=(",", ":"))
    print(f"'{collection}' collection updated with app {app_id}")


def add_steam_shortcut(id, name, target_path, start_dir, icon_path, collection="Emulation", recent=False):
    if system in ("linux", "darwin"):
        # 1) Locate Steam directory
        steam_dir = home / ".steam" / "steam"        
        steam_exe = shutil.which("steam")
        
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
    if system == "linux" and get_product_name() != "frame":
        try:
            pid = subprocess.check_output(["pidof", "steam"], text=True).strip()
            if pid:
                subprocess.run(["kill", "-15", pid], check=False)
        except subprocess.CalledProcessError:
            pass  # Steam no está corriendo
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
    user_dir = os.path.join(steam_dir, 'userdata', user_id)
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
            changed = add_tag(shortcut, collection)
            if changed:
                print(f"Etiqueta '{collection}' añadida al acceso directo existente '{name}'")
            if recent:
                shortcut["LastPlayTime"] = int(time.time())
                changed = True
                print(f"'{name}' marcado como jugado recientemente")
            if changed:
                with open(shortcuts_path, "wb") as f:
                    vdf.binary_dump(shortcuts_data, f)
            existing_id = to_unsigned_app_id(shortcut.get("appid"))
            if existing_id is None:
                existing_id = int(generate_short_app_id(shortcut.get("exe", "").strip('"'), shortcut.get("appname", "")))
            add_to_collection(user_dir, collection, existing_id)
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
        "LastPlayTime": int(time.time()) if recent else 0,
        "tags": build_tags(collection),
        "appid": generate_shortcut_id(target_path, name)
    }

    # Escribir los cambios de vuelta al archivo
    with open(shortcuts_path, "wb") as f:
        vdf.binary_dump(shortcuts_data, f)

    print(f"El acceso directo '{name}' se ha añadido correctamente con AppID {appid} en '{shortcuts_path}'")

    # Crear el directorio para las imágenes si no existe
    os.makedirs(grid_path, exist_ok=True)

    # Copiar imágenes usando el AppID
    copy_steam_images(grid_path, id, appid)

    add_to_collection(user_dir, collection, int(appid))

    if steam_exe:
        subprocess.Popen([steam_exe, "-silent"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


