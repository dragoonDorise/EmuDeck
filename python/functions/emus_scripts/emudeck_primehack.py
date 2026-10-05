from core.all import *


def primehack_install():
    set_msg(f"Installing primehack")

    if system == "linux":
        type="flatpak"
        look_for=""
        destination = emus_folder
        name="PrimeHack"
        repo="io.github.shiiion.primehack"

    if system.startswith("win"):
        name = "primehack"
        type = "zip"
        destination = f"{emus_folder}/primehack"

        repo = get_latest_release_gh(
            repository="shiiion/dolphin",
            fileType="a.zip",                 
            fileNameContains="PrimeHack.Release"
        ) or "https://github.com/shiiion/dolphin/releases/download/1.0.8a/PrimeHack.Release.v1.0.8a.zip"

    if system == "darwin":
        return False

    try:
        install_emu(name, repo, type, destination)
        primehack_install_textures()
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def primehack_install_textures():
    """Descarga las texturas de botones de Steam Deck de la rama main de EmuDeck/primehack-deck-buttons."""
    set_msg("Downloading PrimeHack textures")
    if system == "linux":
        textures_dir = Path(f"{home}/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Load/Textures")
    elif system.startswith("win"):
        textures_dir = Path(f"{emus_folder}/primehack/User/Load/Textures")
    else:
        textures_dir = Path(f"{home}/Library/Application Support/Dolphin/Load/Textures")
    try:
        resp = requests.get("https://github.com/EmuDeck/primehack-deck-buttons/archive/refs/heads/main.zip", timeout=120)
        resp.raise_for_status()

        prefix = "primehack-deck-buttons-main/R3M/"
        with zipfile.ZipFile(BytesIO(resp.content)) as zf:
            for member in zf.infolist():
                if member.is_dir() or not member.filename.startswith(prefix):
                    continue
                target = textures_dir / "R3M" / member.filename[len(prefix):]
                target.parent.mkdir(parents=True, exist_ok=True)
                with zf.open(member) as src, open(target, "wb") as dst:
                    shutil.copyfileobj(src, dst)
        return True
    except Exception as e:
        print(f"Error downloading PrimeHack textures: {e}")
        return False


def primehack_uninstall():
    try:
        if system == "linux":
            uninstall_emu("io.github.shiiion.primehack", "flatpak")
        if system.startswith("win"):
          uninstall_emu("primehack", "dir")
        if system == "darwin":
          uninstall_emu("Primehack", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def primehack_is_installed():
    if system == "linux":
        return is_flatpak_installed("io.github.shiiion.primehack")
    if system.startswith("win"):
      return (emus_folder / "primehack" / "dolphin.exe").exists()
    if system == "darwin":
      return (emus_folder / "Dolphin.app").exists()


def primehack_init():
    set_msg(f"Setting up primehack")
    flush_emulator_launchers("primehack")
    if system == "linux":
        destination=f"{home}/.var/app/io.github.shiiion.primehack/config/dolphin-emu/"
        data_destination=f"{home}/.var/app/io.github.shiiion.primehack/data/dolphin-emu/"
        config_src="common/primehack/config/dolphin-emu/"
        data_src="common/primehack/data/dolphin-emu/"
    if system.startswith("win"):
        destination=f"{emus_folder}/primehack/User/Config/"
        data_destination=f"{emus_folder}/primehack/User/GameSettings/"
        config_src=f"{system}/primehack/User/Config/"
        data_src=f"{system}/primehack/User/GameSettings/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/Dolphin/Config"
        data_destination=f"{home}/Library/Application Support/Dolphin"
        config_src="common/primehack/config/dolphin-emu/"
        data_src="common/primehack/data/dolphin-emu/"

    copy_setting_dir(config_src, destination)
    copy_setting_dir(data_src, data_destination)

    copy_and_set_settings_file(f"{config_src}Dolphin.ini", destination)

    primehack_setup_saves()
    primehack_set_resolution()
    primehack_set_controller_style()
    primehack_set_frame_controllers()


def primehack_set_frame_controllers():
    if system != "linux" or get_product_name() != "frame":
        return
    config_dir = f"{home}/.var/app/io.github.shiiion.primehack/config/dolphin-emu"
    for ini in ("GCPadNew.ini", "WiimoteNew.ini", "Hotkeys.ini"):
        ini_path = Path(config_dir) / ini
        if ini_path.is_file():
            sed("evdev/0/Microsoft X-Box 360 pad 0", "SDL/0/Steam Frame Controllers", ini_path)

def primehack_install_init():
    primehack_install()
    primehack_init()


def primehack_setup_saves():
    saves_folder="primehack/saves"
    if system == "linux":
        origin_saves_gc=f"{home}/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC"
        origin_saves_wii=f"{home}/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii"
        origin_states=f"{home}/.var/app/io.github.shiiion.primehack/data/dolphin-emu/StateSaves"
        saves_folder="primehack"
    if system.startswith("win"):
        origin_saves_gc=f"{emus_folder}/primehack/User/GC"
        origin_saves_wii=f"{emus_folder}/primehack/User/Wii"
        origin_states=f"{emus_folder}/primehack/User/StateSaves"
    if system == "darwin":
        origin_saves_gc=f"{home}/Library/Application Support/Dolphin/GC"
        origin_saves_wii=f"{home}/Library/Application Support/Dolphin/Wii"
        origin_states=f"{home}/Library/Application Support/Dolphin/StateSaves"

    link_to_saves_folder(origin_saves_gc, f"{saves_folder}/GC")
    link_to_saves_folder(origin_saves_wii, f"{saves_folder}/Wii")
    link_to_saves_folder(origin_states, "primehack/StateSaves")


def primehack_set_resolution():
    if system == "linux":
        primehack_config_file=f"{home}/.var/app/io.github.shiiion.primehack/config/dolphin-emu/GFX.ini"
    if system.startswith("win"):
        primehack_config_file=f"{emus_folder}/primehack/User/Config/GFX.ini"
    if system == "darwin":
        primehack_config_file=f"{home}/Library/Application Support/Dolphin/Config/GFX.ini"

    resolution_map = {
        "720P": 2,
        "1080P": 3,
        "1440P": 4,
        "4K": 6,
    }

    config_path = Path(primehack_config_file)

    multiplier = resolution_map.get(settings.resolutions.dolphin, 2)

    if settings.resolutions.dolphin == "4K" and system == "linux" and get_screen_width() < 3840:
        multiplier = 3

    set_config("InternalResolution", multiplier, config_path, " = ")

    return True


def primehack_set_abxy_style():
    print("NYI")

def primehack_set_bayx_style():
    print("NYI")

def primehack_set_controller_style():
    if settings.controllerLayout == "bayx":
        primehack_set_bayx_style()
    else:
        primehack_set_bayx_style()

def primehack_add_to_steam():
    set_msg("Adding PrimeHack to Steam")
    launcher = tools_path / "launchers" / ("primehack.bat" if system.startswith("win") else "primehack.sh")
    add_steam_shortcut("primehack", "PrimeHack", str(launcher), str(emus_folder), str(icons_path / "ico/primehack.ico"))
