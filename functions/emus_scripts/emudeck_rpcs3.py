from core.all import *

def rpcs3_get_download_url():
    api_url = "https://update.rpcs3.net/"
    if system == "linux":
        params = {
            "api":        "v3",
            "os_type":    "linux",
            "os_arch":    "x64",
            "os_version": get_linux_version_id(),
        }
    if system.startswith("win"):
        return get_latest_release_gh("RPCS3/rpcs3-binaries-win","7z","win64")

    if system == "darwin":
        params = {
            "api":        "v3",
            "os_type":    "macos",
            "os_arch":    "arm64"
        }


    # 1) Fetch JSON
    resp = requests.get(api_url, params=params, timeout=10)
    resp.raise_for_status()
    data = resp.json()

    code = data.get("return_code", None)
    # Early exit on error codes
    if code is None or code < 0:
        return code or -99, None, None

    # 2) Pull out download link & remote checksum
    latest = data.get("latest_build", {}).get("linux", {})
    download_url     = latest.get("download")
    remote_checksum  = latest.get("checksum", "").lower()

    return download_url

def rpcs3_install():
    set_msg(f"Installing rpcs3")

    if system == "linux":
        type="AppImage"
        look_for="appimage"
        path=emus_folder

    if system.startswith("win"):
        type="7z"
        look_for="msvc"
        path=f"{emus_folder}/rpcs3"

    if system == "darwin":
        type="7z"
        look_for="macos"
        path=emus_folder

    try:
        repo=rpcs3_get_download_url()
        install_emu("rpcs3", repo, type, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def rpcs3_uninstall():
    try:
        if system == "linux":
            uninstall_emu("rpcs3", "AppImage")
        if system.startswith("win"):
          uninstall_emu("rpcs3", "dir")
        if system == "darwin":
          uninstall_emu("RPCS3", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def rpcs3_is_installed():
    if system == "linux":
        return (emus_folder / "rpcs3.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "rpcs3" / "rpcs3.exe").exists()
    if system == "darwin":
      return (emus_folder / "RPCS3.app").exists()


def rpcs3_init():
    set_msg(f"Setting up rpcs3")
    if system == "linux":
        destination=f"{home}/.config/rpcs3"
    if system.startswith("win"):
        destination=f"{emus_folder}/rpcs3"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/RPCS3/"

    copy_and_set_settings_file(f"common/rpcs3/config.yml", destination)

    rpcs3_setup_storage()
    rpcs3_setup_saves()
    rpcs3_set_resolution()

def rpcs3_install_init():
    rpcs3_install()
    rpcs3_init()



def rpcs3_setup_saves():
    origin_saves=f"{storage_path}/dev_hdd0/home/00000001/savedata"
    origin_trophies=f"{storage_path}/dev_hdd0/home/00000001/trophy"

    move_contents_and_link(origin_saves,f"{saves_path}/rpcs3/saves")
    move_contents_and_link(origin_trophies,f"{saves_path}/rpcs3/trophy")

def rpcs3_setup_storage():
    if system == "linux":
        origin=f"{home}/.config/rpcs3/dev_hdd0"
    if system.startswith("win"):
        origin=f"{emus_folder}/dev_hdd0/sdmc"
    if system == "darwin":
        origin=f"{home}/Library/Application Support/rpcs3/dev_hdd0"

    move_contents_and_link(origin,f"{storage_path}/rpcs3/dev_hdd0")


def rpcs3_set_resolution() -> bool:
    if system == "linux":
        rpcs3_config_file="~/.config/rpcs3/config.yml"
    if system.startswith("win"):
        rpcs3_config_file=f"{emus_folder}/rpcs3/config.yml"
    if system == "darwin":
        rpcs3_config_file=f"{home}/Library/Application Support/rpcs3/config.yml"

    resolution_map = {
        "720P": 100,
        "1080P": 150,
        "1440P": 200,
        "4K": 300,
    }

    # Normalize config file path
    config_path = Path(rpcs3_config_file)

    # Find the multiplier
    multiplier = resolution_map.get(settings.resolutions.rpcs3)
    if multiplier is None:
        print(f"Error: unsupported resolution '{settings.resolutions.rpcs3}'")
        return False

    set_config("Resolution Scale", multiplier, config_path)

    return True