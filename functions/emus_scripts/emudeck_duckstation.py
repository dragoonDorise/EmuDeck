from core.all import *


def duckstation_install():
    set_msg(f"Installing DuckStation")

    if system == "linux":
        name="duckstation"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        name="duckstation"
        type="zip"
        look_for="windows-x64-release.zip"
        destination = f"{emus_folder}/duckstation"

    if system == "darwin":
        name="DuckStation"
        type="zip"
        look_for="mac"
        destination = f"{emus_folder}"

    try:
        if system == "linux":
            repo="org.duckstation.DuckStation"
        else:
            repo=get_latest_release_gh("stenzek/duckstation",type,look_for)

        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def duckstation_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.duckstation.DuckStation", "flatpak")
        if system.startswith("win"):
          uninstall_emu("duckstation", "dir")
        if system == "darwin":
          uninstall_emu("DuckStation", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def duckstation_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.duckstation.DuckStation")
    if system.startswith("win"):
      return (emus_folder / "duckstation" / "duckstation-qt-x64-ReleaseLTCG.exe").exists()
    if system == "darwin":
      return (emus_folder / "DuckStation.app").exists()


def duckstation_init():
    set_msg(f"Setting up duckstation")
    if system == "linux":
        destination=f"{home}/.var/app/org.duckstation.DuckStation/config/duckstation/"
    if system.startswith("win"):
        destination=f"{emus_folder}/duckstation/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/DuckStation"

    copy_setting_dir(f"common/duckstation/",destination)
    copy_and_set_settings_file(f"common/duckstation/settings.ini", destination)

    duckstation_setup_saves()
    #duckstation_setup_storage()
    duckstation_set_resolution()
    duckstation_set_controller_style()
    duckstation_widescreen()

def duckstation_install_init():
    duckstation_install()
    duckstation_init()


def duckstation_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.var/app/org.duckstation.DuckStation/data/duckstation/memcards"
        origin_states=f"{home}/.var/app/org.duckstation.DuckStation/data/duckstation/savestates"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/duckstation/memcards"
        origin_states=f"{emus_folder}/duckstation/savestates"
    if system == "darwin":
        origin_saves=f"{home}/Library/Application Support/DuckStation/memcards"
        origin_states=f"{home}/Library/Application Support/DuckStation/savestates"

    move_contents_and_link(origin_saves,f"{saves_path}/duckstation/saves")
    move_contents_and_link(origin_states,f"{saves_path}/duckstation/states")


def duckstation_set_resolution():
    print("NYI")

def duckstation_set_abxy_style():
    print("NYI")

def duckstation_set_bayx_style():
    print("NYI")

def duckstation_set_controller_style():
    if settings.controllerLayout == "bayx":
        duckstation_set_bayx_style()
    else:
        duckstation_set_bayx_style()

def duckstation_widescreen():
    if settings.ar.classic3d == "169":
        duckstation_widescreen_on()
    else:
        duckstation_widescreen_off()

def duckstation_widescreen_on():
    if system == "linux":
        config_path=f"{home}/.var/app/org.duckstation.DuckStation/config/duckstation/settings.ini"
    if system.startswith("win"):
        config_path=f"{emus_folder}/duckstation/settings.ini"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/DuckStation/settings.ini"

    set_config("WidescreenHack ", " true", config_path)
    set_config("AspectRatio ", " 16:9", config_path)

def duckstation_widescreen_off():
    if system == "linux":
        config_path=f"{home}/.var/app/org.duckstation.DuckStation/config/duckstation/settings.ini"
    if system.startswith("win"):
        config_path=f"{emus_folder}/duckstation/settings.ini"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/DuckStation/settings.ini"

    set_config("WidescreenHack ", " false", config_path)
    set_config("AspectRatio ", " 4:3", config_path)
