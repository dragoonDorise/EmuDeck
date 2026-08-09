from core.all import *

def srm_install():
    set_msg(f"Installing Steam Rom Manager")

    if system == "linux":
        type="AppImage"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        type = "exe"
        look_for = "portable"
        destination = Path(os.environ["APPDATA"]) / "EmuDeck" / "SteamRomManager"
        destination.mkdir(parents=True, exist_ok=True)

    if system == "darwin":
        type="dmg"
        look_for=""
        destination = f"{emus_folder}"

    try:
        if system == "linux" and cpu_arch == "arm":
            repo=get_latest_release_gh("dragoonDorise/steam-rom-manager",type,"arm64.AppImage")
        else:
            repo=get_latest_release_gh("SteamGridDB/steam-rom-manager",type,look_for)

        install_emu("srm", repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def srm_uninstall():
    if system == "linux":
        uninstall_emu("srm", "AppImage")
        shutil.rmtree(tools_path / "launchers" / "srm", ignore_errors=True)

        config_dir = Path(srm_path)
        if config_dir.exists():
            shutil.rmtree(config_dir, ignore_errors=True)
            print(f"Removed config directory at {config_dir}")

    if system.startswith("win"):
        appdata = Path(os.environ["APPDATA"])

        shutil.rmtree(appdata / "EmuDeck" / "SteamRomManager", ignore_errors=True)
        shutil.rmtree(tools_path / "launchers" / "srm", ignore_errors=True)
        (appdata / "Microsoft" / "Windows" / "Start Menu" / "Programs" / "EmuDeck" / "SteamRomManager.lnk").unlink(missing_ok=True)

        # Legacy installation
        shutil.rmtree(tools_path / "userData", ignore_errors=True)
        (tools_path / "srm.exe").unlink(missing_ok=True)

    if system == "darwin":
        uninstall_emu("Steam Rom Manager", "app")

    return True

def srm_is_installed():
    if system == "linux":
        return (emus_folder / "srm.AppImage").exists()
    if system.startswith("win"):
        return (Path(os.environ["APPDATA"]) / "EmuDeck" / "SteamRomManager" / "srm.exe").exists()
    if system == "darwin":
        return (emus_folder / "Steam Rom Manager.app").exists()
    return False

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
