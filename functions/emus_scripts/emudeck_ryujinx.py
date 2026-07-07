from core.all import *

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