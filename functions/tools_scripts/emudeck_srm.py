from core.all import *

def srm_install():
    set_msg(f"Installing Steam Rom Manager")

    if system == "linux":
        type="AppImage"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        type="exe"
        look_for="portable"
        destination = f"{tools_path}"

    if system == "darwin":
        type="dmg"
        look_for=""
        destination = f"{emus_folder}"

    try:
        repo=get_latest_release_gh("SteamGridDB/steam-rom-manager",type,look_for)

        install_emu("srm", repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def srm_uninstall():
    try:
        if system == "linux":
            uninstall_emu("Steam Rom Manager", "AppImage")
        if system.startswith("win"):
            uninstall_emu("srm", "dir")
        if system == "darwin":
            uninstall_emu("Steam Rom Manager", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def srm_is_installed():
    if system == "linux":
        return (tools_path / "Steam Rom Manager.AppImage").exists()
    if system.startswith("win"):
      return (tools_path / "srm.exe").exists()
    if system == "darwin":
      return (emus_folder / "Steam Rom Manager.app").exists()


def srm_init():
    set_msg(f"Setting up Steam Rom Manager")
    copy_setting_dir(f"common/srm/",f"{srm_path}")
    copy_and_set_settings_file(f"common/srm/userData/userSettings.json", f"{srm_path}/userData")
    copy_and_set_settings_file(f"common/srm/userData/userConfigurations.json", f"{srm_path}/userData")
    srm_add_custom_parsers()
    if system.startswith("win"):
        srm_windows_paths()

def srm_windows_paths():
    sed(':\\',':\\\\',f"{srm_path}/userData/userConfigurations.json")
    sed('/','\\\\',f"{srm_path}/userData/userConfigurations.json")
    sed('${\\\\}','${/}',f"{srm_path}/userData/userConfigurations.json")


    sed('\\','\\\\',f"{srm_path}/userData/userSettings.json")
    sed('/','\\\\',f"{srm_path}/userData/userSettings.json")





def srm_install_init():
    srm_install()
    srm_init()

def srm_add_custom_parsers():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
        and name.endswith('_add_custom_parser')
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()
