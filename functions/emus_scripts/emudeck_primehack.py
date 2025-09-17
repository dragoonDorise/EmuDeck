from core.all import *


def primehack_install():
    set_msg(f"Installing dolphin")

    if system == "linux":
        type="flatpak"
        look_for=""
        destination = emus_folder
        name="PrimeHack"
        repo="io.github.shiiion.primehack"

    if system.startswith("win"):
        type="7z"
        look_for=""
        destination = f"{emus_folder}/primehack"
        name="dolphin"
        repo="https://github.com/shiiion/dolphin/releases/download/1.0.7a/PrimeHack.Release.v1.0.7a.zip"

    if system == "darwin":
        return False

    try:
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
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
    set_msg(f"Setting up dolphin")
    if system == "linux":
        destination=f"{home}/.var/app/io.github.shiiion.primehack/config/dolphin-emu/"
    if system.startswith("win"):
        destination=f"{emus_folder}/primehack/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/Dolphin/Config"

    copy_setting_dir(f"{system}/dolphin-emu/",destination)

    if system == "linux":
        copy_and_set_settings_file(f"{system}/dolphin-emu/config/dolphin-emu/Dolphin.ini", f"{destination}")
    if system.startswith("win"):
        copy_and_set_settings_file(f"{system}/dolphin-emu/User/Config/Dolphin.ini", f"{destination}/User/Config/")
    if system == "darwin":
        copy_and_set_settings_file(f"{system}/dolphin-emu/Dolphin.ini", destination)

    primehack_setup_saves()
    primehack_set_resolution()
    primehack_set_controller_style()

def primehack_install_init():
    primehack_install()
    primehack_init()


def primehack_setup_saves():
    if system == "linux":
        origin_saves_gc=f"{home}/.var/app/io.github.shiiion.primehack/data/dolphin-emu/GC"
        origin_saves_wii=f"{home}/.var/app/io.github.shiiion.primehack/data/dolphin-emu/Wii"
        origin_states=f"{home}/.var/app/io.github.shiiion.primehack/data/dolphin-emu/StateSaves"
    if system.startswith("win"):
        origin_saves_gc=f"{emus_folder}/primehack/User/GC"
        origin_saves_wii=f"{emus_folder}/primehack/User/Wii"
        origin_states=f"{emus_folder}/primehack/User/StateSaves"
    if system == "darwin":
        origin_saves_gc=f"{home}/Library/Application Support/Dolphin/GC"
        origin_saves_wii=f"{home}/Library/Application Support/Dolphin/Wii"
        origin_states=f"{home}/Library/Application Support/Dolphin/StateSaves"

    move_contents_and_link(origin_saves_gc,f"{saves_path}/dolphin/saves/GC")
    move_contents_and_link(origin_saves_wii,f"{saves_path}/dolphin/saves/Wii")
    move_contents_and_link(origin_states,f"{saves_path}/dolphin/StateSaves")


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

    # Normalize config file path
    config_path = Path(primehack_config_file)

    # Find the multiplier
    multiplier = resolution_map.get(settings.resolutions.dolphin)
    if multiplier is None:
        print(f"Error: unsupported resolution '{settings.resolutions.dolphin}'")
        return False

    set_config("InternalResolution", multiplier, config_path)

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