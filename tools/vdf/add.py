import os
import sys
import vdf
import zlib
import shutil

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
        src_dir = os.path.expanduser(f"~/AppData/Roaming/EmuDeck/backend/configs/steam-rom-manager/userData/img/emus/{id}")
    else:
        src_dir = os.path.expanduser(f"~/.config/EmuDeck/backend/configs/steam-rom-manager/userData/img/emus/{id}")

    # Definir las rutas de origen y destino
    images = {
        "hero": (f"{src_dir}/{id}_hero.png", f"{grid_path}/{shortcut_id}_hero.png"),
        "logo": (f"{src_dir}/{id}_logo.png", f"{grid_path}/{shortcut_id}_logo.png"),
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


def add_steam_shortcut_with_category(id, name, target_path, start_dir, icon_path, steam_dir, user_id, categories):
    # Ruta del archivo shortcuts.vdf
    shortcuts_path = os.path.join(user_id, "config", "shortcuts.vdf")
    grid_path = os.path.join(user_id, "config", "grid")

    # Leer el archivo actual
    try:
        with open(shortcuts_path, "rb") as f:
            shortcuts_data = vdf.binary_load(f)
    except FileNotFoundError:
        # Crear una estructura básica si no existe el archivo
        shortcuts_data = {"shortcuts": {}}

    # Comprobar si ya existe un acceso directo con el mismo nombre o ruta
    for shortcut in shortcuts_data["shortcuts"].values():
        if shortcut.get("appname") == name or shortcut.get("exe").strip('"') == target_path:
            print(f"El acceso directo '{name}' ya existe en la biblioteca de Steam en '{shortcuts_path}'.")
            return  # Salir sin añadir el acceso directo

    # Buscar el próximo índice disponible
    existing_indices = [int(k) for k in shortcuts_data["shortcuts"].keys()]
    next_index = max(existing_indices, default=-1) + 1

    # Generar un AppID válido
    appid = short_app_id = generate_short_app_id(target_path, name)

    # Crear el nuevo acceso directo
    shortcuts_data["shortcuts"][str(next_index)] = {
        "appname": name,
        "exe": f'"{target_path}"',
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
        "tags": {str(i): category for i, category in enumerate(categories)}
    }

    # Modificación directa del `appid` después de cargar los datos
    shortcuts_data["shortcuts"][str(next_index)]["appid"] = appid

    # Escribir los cambios de vuelta al archivo
    with open(shortcuts_path, "wb") as f:
        vdf.binary_dump(shortcuts_data, f)

    print(f"El acceso directo '{name}' se ha añadido correctamente con AppID {appid} en '{shortcuts_path}'")

    # Crear el directorio para las imágenes si no existe
    os.makedirs(grid_path, exist_ok=True)

    # Copiar imágenes usando el AppID
    copy_steam_images(grid_path, id, appid)


# Llamar a la función principal con categorías
add_steam_shortcut_with_category(
    id=sys.argv[1],
    name=sys.argv[2],
    target_path=sys.argv[3],
    start_dir=sys.argv[4],
    icon_path=sys.argv[5],
    steam_dir=sys.argv[6],
    user_id=sys.argv[7],
    categories=sys.argv[8:]  # Pasar las categorías como una lista
)
