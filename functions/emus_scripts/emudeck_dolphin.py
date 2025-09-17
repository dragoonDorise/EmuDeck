from core.all import *

def dolphin_get_download_url() -> Optional[str]:
    download_page = "https://es.dolphin-emu.org/download/?ref=btn"
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/114.0.0.0 Safari/537.36"
        ),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    }
    try:
        resp = requests.get(download_page, headers=headers, timeout=10)
        resp.raise_for_status()
    except Exception as e:
        print(f"Error fetching download page: {e}")
        return None

    html = resp.text

    if system == "linux":
        return "org.DolphinEmu.dolphin-emu"

    if system.startswith("win"):
        pattern = re.compile(
            r"https://dl\.dolphin-emu\.org/releases/[A-Za-z0-9_]+/"
            r"dolphin-[A-Za-z0-9_]+-x64\.7z"
        )

    if system == "darwin":
        pattern = re.compile(
            r"https://dl\.dolphin-emu\.org/releases/[A-Za-z0-9_]+/"
            r"dolphin-[A-Za-z0-9_]+-universal\.dmg"
        )

    urls = re.findall(pattern, html)

    filtered = [u for u in urls if "-DEV" not in u]

    return filtered[0] if filtered else None


def dolphin_install():
    set_msg(f"Installing dolphin")

    if system == "linux":
        type="flatpak"
        look_for=""
        destination = emus_folder
        name="Dolphin"

    if system.startswith("win"):
        type="7z"
        look_for=""
        destination = f"{emus_folder}/Dolphin-x64"
        name="Dolphin"

    if system == "darwin":
        type="dmg"
        look_for=""
        destination = emus_folder
        name="Dolphin"

    try:
        install_emu(name, dolphin_get_download_url(), type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def dolphin_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.DolphinEmu.dolphin-emu", "flatpak")
        if system.startswith("win"):
          uninstall_emu("Dolphin-x64", "dir")
        if system == "darwin":
          uninstall_emu("Dolphin", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def dolphin_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.DolphinEmu.dolphin-emu")
    if system.startswith("win"):
      return (emus_folder / "Dolphin-x64" / "dolphin.exe").exists()
    if system == "darwin":
      return (emus_folder / "Dolphin.app").exists()


def dolphin_init():
    set_msg(f"Setting up dolphin")
    if system == "linux":
        destination=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/"
    if system.startswith("win"):
        destination=f"{emus_folder}/Dolphin-x64/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/Dolphin/Config"

    copy_setting_dir(f"{system}/dolphin-emu/",destination)

    if system == "linux":
        copy_and_set_settings_file(f"{system}/dolphin-emu/config/dolphin-emu/Dolphin.ini", f"{destination}")
    if system.startswith("win"):
        copy_and_set_settings_file(f"{system}/dolphin-emu/User/Config/Dolphin.ini", f"{destination}/User/Config/")
    if system == "darwin":
        copy_and_set_settings_file(f"{system}/dolphin-emu/Dolphin.ini", destination)

    dolphin_setup_saves()
    dolphin_set_resolution()
    dolphin_set_controller_style()
    dolphin_widescreen()

def dolphin_install_init():
    dolphin_install()
    dolphin_init()

def dolphin_setup_saves():
    if system == "linux":
        origin_saves_gc=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC"
        origin_saves_wii=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii"
        origin_states=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves"
    if system.startswith("win"):
        origin_saves_gc=f"{emus_folder}/Dolphin-x64/User/GC"
        origin_saves_wii=f"{emus_folder}/Dolphin-x64/User/Wii"
        origin_states=f"{emus_folder}/Dolphin-x64/User/StateSaves"
    if system == "darwin":
        origin_saves_gc=f"{home}/Library/Application Support/Dolphin/GC"
        origin_saves_wii=f"{home}/Library/Application Support/Dolphin/Wii"
        origin_states=f"{home}/Library/Application Support/Dolphin/StateSaves"

    move_contents_and_link(origin_saves_gc,f"{saves_path}/dolphin/saves/GC")
    move_contents_and_link(origin_saves_wii,f"{saves_path}/dolphin/saves/Wii")
    move_contents_and_link(origin_states,f"{saves_path}/dolphin/StateSaves")


def dolphin_set_resolution():
    if system == "linux":
        dolphin_config_file=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    if system.startswith("win"):
        dolphin_config_file=f"{emus_folder}/Dolphin-x64/User/Config/GFX.ini"
    if system == "darwin":
        dolphin_config_file=f"{home}/Library/Application Support/Dolphin/Config/GFX.ini"

    resolution_map = {
        "720P": 2,
        "1080P": 3,
        "1440P": 4,
        "4K": 6,
    }

    # Normalize config file path
    config_path = Path(dolphin_config_file)

    # Find the multiplier
    multiplier = resolution_map.get(settings.resolutions.dolphin)
    if multiplier is None:
        print(f"Error: unsupported resolution '{settings.resolutions.dolphin}'")
        return False

    set_config("InternalResolution", multiplier, config_path)

    return True


def dolphin_set_abxy_style():
    print("NYI")

def dolphin_set_bayx_style():
    print("NYI")

def dolphin_set_controller_style():
    if settings.controllerLayout == "bayx":
        dolphin_set_bayx_style()
    else:
        dolphin_set_bayx_style()

def dolphin_widescreen_on():
    if system == "linux":
        dolphin_config_file=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    if system.startswith("win"):
        dolphin_config_file=f"{emus_folder}/Dolphin-x64/User/Config/GFX.ini"
    if system == "darwin":
        dolphin_config_file=f"{home}/Library/Application Support/Dolphin/Config/GFX.ini"
    config_path = Path(dolphin_config_file)

    set_config("wideScreenHack", "True", config_path)
    set_config("AspectRatio", "1", config_path)

def dolphin_widescreen_off():
    if system == "linux":
        dolphin_config_file=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    if system.startswith("win"):
        dolphin_config_file=f"{emus_folder}/Dolphin-x64/User/Config/GFX.ini"
    if system == "darwin":
        dolphin_config_file=f"{home}/Library/Application Support/Dolphin/Config/GFX.ini"
    config_path = Path(dolphin_config_file)

    set_config("wideScreenHack", "False", config_path)
    set_config("AspectRatio", "0", config_path)


def dolphin_widescreen():
    if settings.ar.dolphin == "169":
        dolphin_widescreen_on()
    else:
        dolphin_widescreen_off()