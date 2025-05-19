from core.all import *

def bigpemu_get_download_url() -> Optional[str]:
    download_page = "https://www.richwhitehouse.com/jaguar/index.php?content=download"
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
        pattern = r"https://www\.richwhitehouse\.com/jaguar/builds/BigPEmu_Linux64_v[0-9]+\.tar\.gz"
    if system.startswith("win"):
        pattern = r"https://www\.richwhitehouse\.com/jaguar/builds/BigPEmu_v[0-9]+\.zip"
    urls = re.findall(pattern, html)

    filtered = [u for u in urls if "-DEV" not in u]

    return filtered[0] if filtered else None

def bigpemu_install():
    set_msg(f"Installing bigpemu")

    if system == "linux":
        type="tar.gz"
        destination = emus_folder

    if system.startswith("win"):
        type="zip"
        destination = emus_folder / "bigpemu"

    if system == "darwin":
        return

    try:
        install_emu("bigpemu", bigpemu_get_download_url(), type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def bigpemu_uninstall():
    try:
        if system == "linux":
            uninstall_emu("bigpemu", "AppImage")
        if system.startswith("win"):
          uninstall_emu("bigpemu", "dir")
        if system == "darwin":
          return
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def bigpemu_is_installed():
    if system == "linux":
        return (emus_folder / "bigpemu" / "bigpemu").exists()
    if system.startswith("win"):
      return (emus_folder / "bigpemu" / "bigpemu.exe").exists()
    if system == "darwin":
      return


def bigpemu_init():
    set_msg(f"Setting up bigpemu")
    if system == "linux":
        destination=f"{emus_folder}/bigpemu/"
    if system.startswith("win"):
        destination=f"{emus_folder}/bigpemu/"
    if system == "darwin":
        return

    copy_and_set_settings_file(f"common/bigpemu/BigPEmuConfig.bigpcfg", destination)

    bigpemu_setup_saves()
    bigpemu_set_resolution()
    bigpemu_set_controller_style()
    esde_set_emu("BigPEmu (Standalone)","atarijaguarcd")
    esde_set_emu("BigPEmu (Standalone)","atarijaguar")
    bigpemu_add_custom_parser()

def bigpemu_install_init():
    bigpemu_install()
    bigpemu_init()


def bigpemu_add_custom_parser():
    if bigpemu_is_installed():
        add_parser("atari_jaguar_bigpemu")


def bigpemu_setup_saves():
    if system == "linux":
        origin_saves=f"{emus_folder}/bigpemu/UserData"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/bigpemu/UserData"
    if system == "darwin":
        return

    move_contents_and_link(origin_saves,f"{saves_path}/BigPEmu/saves")



def bigpemu_set_resolution():
    print("NYI")

def bigpemu_set_abxy_style():
    print("NYI")

def bigpemu_set_bayx_style():
    print("NYI")

def bigpemu_set_controller_style():
    if settings.controllerLayout == "bayx":
        bigpemu_set_bayx_style()
    else:
        bigpemu_set_bayx_style()