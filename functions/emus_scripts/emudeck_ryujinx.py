from core.all import *
import ctypes
import json

if system == "linux":
    ryujinx_config_file = f"{home}/.config/Ryujinx/Config.json"
if system.startswith("win"):
    ryujinx_config_file = f"{emus_folder}/Ryujinx/portable/Config.json"
if system == "darwin":
    ryujinx_config_file = f"{home}/Library/Application Support/Ryujinx/Config.json"

def ryujinx_get_url():
    if system == "linux":
        exename = "arm64.AppImage" if cpu_arch == "arm" else "x64.AppImage"
    elif system.startswith("win"):
        exename = "win_x64.zip"
    elif system == "darwin":
        exename = "macos_universal.app.tar.gz"
    else:
        raise ValueError(f"Unsupported system: {system}")

    resp = requests.get(
        "https://git.ryujinx.app/api/v1/repos/Ryubing/Canary/releases/latest",
        headers={"User-Agent": "EmuDeck"},
        timeout=10,
    )
    resp.raise_for_status()
    release = resp.json()

    for asset in release.get("assets", []):
        if exename in asset.get("name", ""):
            return asset.get("browser_download_url")

    raise RuntimeError(f"No release asset named '{exename}' found")


def ryujinx_install():
    set_msg("Installing ryujinx")
    repo = ryujinx_get_url()

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_dir = Path(temp_dir)

        if system.startswith("win"):
            destination = Path(emus_folder) / "Ryujinx"
            target = temp_dir / "ryujinx.zip"

        elif system == "linux":
            destination = Path(emus_folder) / "ryujinx.AppImage"
            target = destination

        elif system == "darwin":
            return install_emu("ryujinx", repo, "tar.gz", emus_folder)

        else:
            raise ValueError(f"Unsupported system: {system}")

        response = requests.get(
            repo,
            stream=True,
            headers={"User-Agent": "EmuDeck"},
            timeout=30,
        )
        response.raise_for_status()

        with open(target, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

        if system.startswith("win"):
            extract_dir = temp_dir / "ryujinx"

            with zipfile.ZipFile(target, "r") as zf:
                zf.extractall(extract_dir)

            source_dir = extract_dir / "publish"
            if not source_dir.exists():
                raise RuntimeError(f"'publish' folder not found in extracted Ryujinx zip: {extract_dir}")

            shutil.copytree(source_dir, destination, dirs_exist_ok=True)

        elif system == "linux":
            destination.chmod(0o755)

    create_app_shortcut("ryujinx")
    return True



def ryujinx_uninstall():
    try:
        if system == "linux":
            uninstall_emu("ryujinx", "AppImage")
        if system.startswith("win"):
          uninstall_emu("ryujinx", "dir")
        if system == "darwin":
          uninstall_emu("ryujinx", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def ryujinx_is_installed():
    if system == "linux":
        return (emus_folder / "ryujinx.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "ryujinx" / "ryujinx.exe").exists()
    if system == "darwin":
      return (emus_folder / "ryujinx.app").exists()


def ryujinx_init():
    set_msg("Setting up ryujinx")

    if system == "linux":
        destination = f"{home}/.config/Ryujinx/"
    elif system.startswith("win"):
        destination = f"{emus_folder}/Ryujinx/portable/"
    elif system == "darwin":
        destination = f"{home}/Library/Application Support/Ryujinx/"
    else:
        raise ValueError(f"Unsupported system: {system}")

    copy_and_set_settings_file(f"{system}/ryujinx/Config.json", destination)

    ryujinx_setup_saves()
    ryujinx_set_resolution()
    ryujinx_set_controller_style()
    ryujinx_ensure_gyro_dsu()
    esde_set_emu("Ryujinx (Standalone)", "switch")
    return True

def ryujinx_install_init():
    ryujinx_install()
    ryujinx_init()


def ryujinx_setup_saves():
    if system == "linux":
        saves = f"{home}/.config/Ryujinx/bis/user/save"
        saveMeta = f"{home}/.config/Ryujinx/bis/user/saveMeta"
        system_saves = f"{home}/.config/Ryujinx/bis/system/save"
        system_internal = f"{home}/.config/Ryujinx/system"

    elif system.startswith("win"):
        saves = f"{emus_folder}/Ryujinx/portable/bis/user/save"
        saveMeta = f"{emus_folder}/Ryujinx/portable/bis/user/saveMeta"
        system_saves = f"{emus_folder}/Ryujinx/portable/bis/system/save"
        system_internal = f"{emus_folder}/Ryujinx/portable/system"

    elif system == "darwin":
        saves = f"{home}/Library/Application Support/Ryujinx/bis/user/save"
        saveMeta = f"{home}/Library/Application Support/Ryujinx/bis/user/saveMeta"
        system_saves = f"{home}/Library/Application Support/Ryujinx/bis/system/save"
        system_internal = f"{home}/Library/Application Support/Ryujinx/system"

    move_contents_and_link(saves, f"{saves_path}/ryujinx/saves")
    move_contents_and_link(saveMeta, f"{saves_path}/ryujinx/saveMeta")
    move_contents_and_link(system_saves, f"{saves_path}/ryujinx/system_saves")
    move_contents_and_link(system_internal, f"{saves_path}/ryujinx/system")

# def ryujinx_setup_storage():
#     if system == "linux":
#         origin_saves=f"{home}/.share/ryujinx/sdmc"
#         origin_states=f"{home}/.local/share/ryujinx-emu/states"
#     if system.startswith("win"):
#         origin_saves=f"{emus_folder}/ryujinx/sdmc"
#         origin_states=f"{emus_folder}/ryujinx/states"
#     if system == "darwin":
#         origin_saves=f"{home}/.share/ryujinx/sdmc"
#         origin_states=f"{home}/.local/share/ryujinx-emu/states"
# 
#     move_contents_and_link(origin_saves,f"{saves_path}/ryujinx/saves")
#     move_contents_and_link(origin_states,f"{saves_path}/ryujinx/states")


def ryujinx_set_resolution() -> bool:
    resolution_map = {
        "720P": 1,
        "1080P": 1,
        "1440P": 2,
        "4K": 2,
    }

    docked_mode_map = {
        "720P": False,
        "1080P": True,
        "1440P": False,
        "4K": True,
    }

    # Normalize config file path
    config_path = Path(ryujinx_config_file)

    # Find the multiplier
    multiplier = resolution_map.get(settings.resolutions.ryujinx)
    docked_mode_map = docked_mode_map.get(settings.resolutions.ryujinx)
    if multiplier is None:
        print(f"Error: unsupported resolution '{settings.resolutions.ryujinx}'")
        return False

    update_json_key("res_scale", multiplier, ryujinx_config_file)
    update_json_key("docked_mode", docked_mode_map, ryujinx_config_file)

    return True

def ryujinx_set_abxy_style():
    sed('"button_x": "Y"','"button_x": "X"',ryujinx_config_file)
    sed('"button_b": "A"','"button_x": "B"',ryujinx_config_file)
    sed('"button_y": "X"','"button_x": "Y"',ryujinx_config_file)
    sed('"button_a": "B"','"button_x": "A"',ryujinx_config_file)

def ryujinx_set_bayx_style():
    sed('"button_x": "X"','"button_x": "Y"',ryujinx_config_file)
    sed('"button_b": "B"','"button_x": "A"',ryujinx_config_file)
    sed('"button_y": "Y"','"button_x": "X"',ryujinx_config_file)
    sed('"button_a": "A"','"button_x": "B"',ryujinx_config_file)


def ryujinx_set_controller_style():
    if settings.controllerLayout == "bayx":
        ryujinx_set_bayx_style()
    else:
        ryujinx_set_bayx_style()


def _ryujinx_sdl_lib_candidates():
    if system == "linux":
        return [
            f"{emus_folder}/publish/libSDL3.so",
            "/usr/lib/libSDL3.so",
            "/usr/lib/libSDL3.so.0",
            "/usr/lib64/libSDL3.so",
        ]
    if system.startswith("win"):
        return [
            f"{emus_folder}/Ryujinx/SDL3.dll",
            "SDL3.dll",
        ]
    if system == "darwin":
        return [
            f"{emus_folder}/ryujinx.app/Contents/Frameworks/libSDL3.dylib",
            f"{emus_folder}/ryujinx.app/Contents/MacOS/libSDL3.dylib",
            "/usr/local/lib/libSDL3.dylib",
            "/opt/homebrew/lib/libSDL3.dylib",
        ]
    return []


RYUJINX_BUILTIN_DEVICES = {
    (0x28DE, 0x1205), (0x28DE, 0x1206),
    (0x0B05, 0x1ABE), (0x0B05, 0x1B4C),
    (0x17EF, 0x6182), (0x17EF, 0x6183),
    (0x17EF, 0x6184), (0x17EF, 0x6185),
}
RYUJINX_BUILTIN_NAME_HINTS = ("steam deck", "rog ally", "legion go", "ayaneo", "aya neo", "onexplayer")

RYUJINX_MOTION_DSU = {
    "slot": 0,
    "alt_slot": 0,
    "mirror_input": False,
    "dsu_server_host": "127.0.0.1",
    "dsu_server_port": 26760,
    "motion_backend": "CemuHook",
    "sensitivity": 100,
    "gyro_deadzone": 1,
    "enable_motion": True,
}

RYUJINX_PLAYERS = ["Player1", "Player2", "Player3", "Player4"]


def _ryujinx_is_builtin(vendor, product, name):
    return (vendor, product) in RYUJINX_BUILTIN_DEVICES \
        or any(hint in (name or "").lower() for hint in RYUJINX_BUILTIN_NAME_HINTS)


def _ryujinx_load_sdl():
    lib = None
    for candidate in _ryujinx_sdl_lib_candidates():
        try:
            lib = ctypes.CDLL(candidate)
            break
        except OSError:
            continue
    if lib is None:
        print("Ryujinx gamepad detection: no SDL3 library found")
        return None

    class _GUID(ctypes.Structure):
        _fields_ = [("data", ctypes.c_uint8 * 16)]

    try:
        lib.SDL_Init.argtypes = [ctypes.c_uint32]
        lib.SDL_Init.restype = ctypes.c_bool
        lib.SDL_GetGamepads.argtypes = [ctypes.POINTER(ctypes.c_int)]
        lib.SDL_GetGamepads.restype = ctypes.POINTER(ctypes.c_uint32)
        lib.SDL_GetJoystickNameForID.argtypes = [ctypes.c_uint32]
        lib.SDL_GetJoystickNameForID.restype = ctypes.c_char_p
        lib.SDL_GetJoystickGUIDForID.argtypes = [ctypes.c_uint32]
        lib.SDL_GetJoystickGUIDForID.restype = _GUID
    except AttributeError as e:
        print(f"Ryujinx gamepad detection: unusable SDL library ({e})")
        return None

    return lib


def _ryujinx_read_gamepads():
    lib = _ryujinx_load_sdl()
    if lib is None:
        return []

    SDL_INIT_GAMEPAD = 0x00002000
    if not lib.SDL_Init(SDL_INIT_GAMEPAD):
        print("Ryujinx gamepad detection: SDL_Init failed")
        return []

    pads = []
    seen = {}
    try:
        count = ctypes.c_int(0)
        ids = lib.SDL_GetGamepads(ctypes.byref(count))
        for i in range(count.value):
            jid = ids[i]
            b = bytes(lib.SDL_GetJoystickGUIDForID(jid).data)
            raw_name = lib.SDL_GetJoystickNameForID(jid)
            name = raw_name.decode() if raw_name else "Unknown Controller"

            h = lambda i: f"{b[i]:02x}"
            tail = "".join(f"{x:02x}" for x in b[10:16])
            guid = f"0000{h(1)}{h(0)}-{h(5)}{h(4)}-{h(6)}{h(7)}-{h(8)}{h(9)}-{tail}"
            vendor = b[4] | (b[5] << 8)
            product = b[8] | (b[9] << 8)
            builtin = _ryujinx_is_builtin(vendor, product, name)
            dup = seen.get(guid, 0)
            seen[guid] = dup + 1
            pads.append({
                "id": f"{dup}-{guid}",
                "name": f"{name} ({dup})",
                "is_builtin": builtin,
            })
    finally:
        lib.SDL_Quit()

    return pads


def ryujinx_gamepad_count():
    return len(_ryujinx_read_gamepads())


def ryujinx_get_ordered_gamepads():
    pads = _ryujinx_read_gamepads()
    if len(pads) > 1:
        pads = [p for p in pads if not p["is_builtin"]] + [p for p in pads if p["is_builtin"]]
    pads = pads[:4]
    return [
        {"player": RYUJINX_PLAYERS[i], "id": p["id"], "name": p["name"]}
        for i, p in enumerate(pads)
    ]


def ryujinx_set_gamepad_name():
    pads = ryujinx_get_ordered_gamepads()
    if not pads:
        print("No controller detected, keeping existing Ryujinx input config")
        return False

    print(f"Detected gamepads: {[{'player': p['player'], 'name': p['name']} for p in pads]}")

    config_path = Path(ryujinx_config_file)
    if not config_path.exists():
        print(f"{config_path} not found")
        return False

    with config_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    entries = data.get("input_config") or []
    template = next(
        (e for e in entries if str(e.get("backend", "")).startswith("Gamepad")),
        entries[0] if entries else None,
    )
    if template is None:
        print("No gamepad entry in input_config, nothing to update")
        return False

    backend = template.get("backend", "")
    if not str(backend).startswith("Gamepad"):
        backend = "GamepadSDL3"

    new_entries = []
    for pad in pads:
        entry = json.loads(json.dumps(template))
        entry["player_index"] = pad["player"]
        entry["id"] = pad["id"]
        entry["name"] = pad["name"]
        entry["backend"] = backend
        new_entries.append(entry)

    if len(pads) == 1 and "steam deck" in pads[0]["name"].lower():
        new_entries[0]["motion"] = json.loads(json.dumps(RYUJINX_MOTION_DSU))

    data["input_config"] = new_entries

    tmp_path = config_path.with_suffix(config_path.suffix + ".tmp")
    with tmp_path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write("\n")
    tmp_path.replace(config_path)

    return True


def _ryujinx_uses_sdl2_backend():
    config_path = Path(ryujinx_config_file)
    if not config_path.exists():
        return False
    try:
        with config_path.open("r", encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, ValueError):
        return False
    entries = data.get("input_config") or []
    return any(str(e.get("backend", "")).startswith("GamepadSDL2") for e in entries)


def ryujinx_migrate_to_sdl3():
    print("Ryujinx: migrating input backend to SDL3")
    if not ryujinx_install():
        print("Ryujinx: SDL3 migration failed while reinstalling")
        return False
    if not ryujinx_init():
        print("Ryujinx: SDL3 migration failed while applying configuration")
        return False
    return True


def ryujinx_ensure_gyro_dsu():
    if get_product_name() not in ("Jupiter", "Galileo"):
        return
    if (Path(home) / "sdgyrodsu" / "sdgyrodsu").is_file():
        return
    plugins_install_steamdeck_gyro_dsu()


def ryujinx_launch_fixes():
    if ryujinx_is_installed() and _ryujinx_uses_sdl2_backend():
        ryujinx_migrate_to_sdl3()
    ryujinx_ensure_gyro_dsu()
    if system == "linux" and ryujinx_gamepad_count() > 1:
        os.environ["SDL_GAMECONTROLLER_IGNORE_DEVICES"] = "0x28de/0x11ff"
        os.environ["SDL_JOYSTICK_IGNORE_DEVICES"] = "0x28de/0x11ff"
    ryujinx_set_gamepad_name()