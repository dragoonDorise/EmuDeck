from core.all import *

SUPERMODEL_GAMES_LIST = "https://raw.githubusercontent.com/trzy/Supermodel/master/Config/Games.xml"


def supermodel_install():
    set_msg(f"Installing Supermodel")

    if system == "linux":
        name="supermodel"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"
        repo="com.supermodel3.Supermodel"

    if system.startswith("win"):
        name="supermodel"
        type="zip"
        look_for="win64"
        destination = f"{emus_folder}/Supermodel"
        repo = get_latest_release_gh("trzy/Supermodel", "zip", "windows.zip")

    if system == "darwin":
        name="supermodel"
        type="zip"
        look_for="macOS"
        destination = f"{emus_folder}"

    try:

        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def supermodel_uninstall():
    try:
        if system == "linux":
            uninstall_emu("com.supermodel3.Supermodel", "flatpak")
        if system.startswith("win"):
          uninstall_emu("supermodel", "dir")
        if system == "darwin":
          uninstall_emu("supermodel", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def supermodel_is_installed():
    if system == "linux":
        return is_flatpak_installed("com.supermodel3.Supermodel")
    if system.startswith("win"):
      return (emus_folder / "supermodel" / "supermodel.exe").exists()
    if system == "darwin":
      return (emus_folder / "supermodel.app").exists()


def supermodel_init():
    set_msg(f"Setting up Supermodel")
    flush_emulator_launchers("supermodel")
    if system == "linux":
        destination=f"{home}/.supermodel/"
    if system.startswith("win"):
        destination=f"{emus_folder}/supermodel/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/supermodel"

    copy_setting_dir(f"common/supermodel/",destination)
    copy_and_set_settings_file(f"common/supermodel/Config/Supermodel.ini", f"{destination}/Config")
    supermodel_update_games_list(f"{destination}/Config/Games.xml")
    supermodel_add_steam_input_profile()



def supermodel_update_games_list(destination) -> bool:
    try:
        r = requests.get(SUPERMODEL_GAMES_LIST, timeout=30)
        r.raise_for_status()
    except Exception as e:
        return False

    if not r.content.strip():
        return False

    Path(destination).write_bytes(r.content)

    return True

def supermodel_install_init():
    supermodel_install()
    supermodel_init()

def supermodel_add_to_steam():
    set_msg("Adding Supermodel to Steam")
    launcher = tools_path / "launchers" / ("supermodel.bat" if system.startswith("win") else "supermodel.sh")
    add_steam_shortcut("supermodel", "Supermodel", str(launcher), str(emus_folder), str(icons_path / "ico/supermodel.ico"))


def supermodel_add_steam_input_profile():
    set_msg("Adding Supermodel Steam Input Profile.")
    add_steam_input_templates("emudeck_steam_deck_light_gun_controls.vdf")
