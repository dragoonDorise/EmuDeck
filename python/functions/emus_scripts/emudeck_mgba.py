from core.all import *

def mgba_install():
    set_msg(f"Installing mgba")

    if system == "linux":
        type="appimage"
        look_for="arm64.appimage" if cpu_arch == "arm" else "x64.appimage"
        path=emus_folder

    if system.startswith("win"):
        type="7z"
        look_for="win64.7z"
        path=f"{emus_folder}/mgba"

    if system == "darwin":
        type="dmg"
        look_for="macos"
        path=emus_folder

    try:
        repo=get_latest_release_gh("mgba-emu/mgba",type,look_for)
        install_emu("mGBA", repo, type, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def mgba_uninstall():
    try:
        if system == "linux":
            uninstall_emu("mGBA", "AppImage")
        if system.startswith("win"):
          uninstall_emu("mgba", "dir")
        if system == "darwin":
          uninstall_emu("mgba", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def mgba_is_installed():
    if system == "linux":
        return (emus_folder / "mGBA.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "mgba" / "mgba.exe").exists()
    if system == "darwin":
      return (emus_folder / "mgba.app").exists()


def mgba_init():
    set_msg(f"Setting up mgba")
    flush_emulator_launchers("mgba")
    if system == "linux":
        destination=f"{home}/.config/mgba"
    if system.startswith("win"):
        destination=f"{emus_folder}/mgba"
    if system == "darwin":
        destination=f"{home}/.config/mgba"

    copy_setting_dir(f"common/mgba/", destination)
    copy_and_set_settings_file(f"common/mgba/config.ini", destination)

    mgba_setup_storage()
    mgba_setup_saves()
    mgba_set_controller_style()
    mgba_set_esde_emu()
    mgba_add_custom_parser()
    mgba_add_steam_input_profile()

def mgba_install_init():
    mgba_install()
    mgba_init()

def mgba_add_custom_parser():
    if mgba_is_installed() and srm_is_installed():
        add_parser("nintendo_gba_mgba")


def mgba_set_abxy_style():
    print("NYI")

def mgba_set_bayx_style():
    print("NYI")

def mgba_set_controller_style():
    if settings.controllerLayout == "bayx":
        mgba_set_bayx_style()
    else:
        mgba_set_bayx_style()

def mgba_add_to_steam():
    set_msg("Adding mGBA to Steam")
    launcher = tools_path / "launchers" / ("mgba.bat" if system.startswith("win") else "mgba.sh")
    add_steam_shortcut("mgba", "mGBA", str(launcher), str(emus_folder), str(icons_path / "ico/mgba.ico"))


def mgba_set_esde_emu():
    if not esde_is_installed():
        return
    esde_set_emu("mGBA (Standalone)", "gba")


def mgba_add_steam_input_profile():
    add_steam_input_custom_icons()
    set_msg("Adding mGBA Steam Input Profile.")
    add_steam_input_templates()


def mgba_setup_saves():
    for folder in ("saves", "states"):
        Path(f"{saves_path}/mgba/{folder}").mkdir(parents=True, exist_ok=True)
    if system == "linux":
        config_file = home / ".config" / "mgba" / "config.ini"
    if system.startswith("win"):
        config_file = emus_folder / "mgba" / "config.ini"
    if system == "darwin":
        config_file = home / ".config" / "mgba" / "config.ini"
    if config_file.is_file():
        set_config("savegamePath", f"{saves_path}/mgba/saves", config_file)
        set_config("savestatePath", f"{saves_path}/mgba/states", config_file)
    return True


def mgba_setup_storage():
    for folder in ("cheats", "patches", "screenshots"):
        Path(f"{storage_path}/mgba/{folder}").mkdir(parents=True, exist_ok=True)
    if system == "linux":
        config_file = home / ".config" / "mgba" / "config.ini"
    if system.startswith("win"):
        config_file = emus_folder / "mgba" / "config.ini"
    if system == "darwin":
        config_file = home / ".config" / "mgba" / "config.ini"
    if config_file.is_file():
        set_config("cheatsPath", f"{storage_path}/mgba/cheats", config_file)
        set_config("patchPath", f"{storage_path}/mgba/patches", config_file)
        set_config("screenshotPath", f"{storage_path}/mgba/screenshots", config_file)
    return True
