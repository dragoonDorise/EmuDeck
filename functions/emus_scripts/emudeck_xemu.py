from core.all import *


def xemu_install():
    set_msg(f"Installing Xemu")

    if system == "linux":
        name="app.xemu.xemu"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        name="xemu"
        type="zip"
        look_for="win-x86_64-release.zip"
        destination = f"{emus_folder}/xemu"

    if system == "darwin":
        name="xemu"
        type="zip"
        look_for="macos-universal"
        destination = f"{emus_folder}"

    try:
        repo=get_latest_release_gh("xemu-project/xemu",type,look_for)
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def xemu_uninstall():
    try:
        if system == "linux":
            uninstall_emu("app.xemu.xemu", "flatpak")
        if system.startswith("win"):
          uninstall_emu("xemu", "dir")
        if system == "darwin":
          uninstall_emu("xemu", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def xemu_is_installed():
    if system == "linux":
        return is_flatpak_installed("app.xemu.xemu")
    if system.startswith("win"):
      return (emus_folder / "xemu" / "xemu.exe").exists()
    if system == "darwin":
      return (emus_folder / "xemu.app").exists()


def xemu_init():
    set_msg(f"Setting up xemu")
    if system == "linux":
        destination=f"{home}/.var/app/app.xemu.xemu/data/xemu/xemu"
    if system.startswith("win"):
        destination=f"{emus_folder}/xemu/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/xemu"

    copy_setting_dir(f"common/xemu/",destination)
    copy_and_set_settings_file(f"common/xemu/xemu.toml", destination)

    xemu_setup_storage()
    xemu_set_resolution()
    xemu_widescreen()

def xemu_install_init():
    xemu_install()
    xemu_init()


def xemu_setup_storage():
   dest_dir=Path(storage_path / "xemu")
   dest_dir.mkdir(parents=True, exist_ok=True)
    # 2) Download ZIP
   url = "https://github.com/mborgerson/xemu-hdd-image/releases/latest/download/xbox_hdd.qcow2.zip"
   zip_path = dest_dir / "xbox_hdd.qcow2.zip"
   response = requests.get(url, stream=True, timeout=30)
   response.raise_for_status()
   with open(zip_path, "wb") as f:
      for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)

   # 3) Extract all files, ignoring internal folders
   with zipfile.ZipFile(zip_path, "r") as zf:
      for info in zf.infolist():
            if info.is_dir():
               continue
            filename = Path(info.filename).name
            target = dest_dir / filename
            with zf.open(info) as src, open(target, "wb") as dst:
               dst.write(src.read())

   # 4) Clean up the ZIP
   zip_path.unlink()

def xemu_set_resolution():
 print("NYI")

def xemu_set_abxy_style():
    print("NYI")

def xemu_set_bayx_style():
    print("NYI")

def xemu_set_controller_style():
    if settings.controllerLayout == "bayx":
        xemu_set_bayx_style()
    else:
        xemu_set_bayx_style()

def xemu_widescreen():
    if settings.ar.classic3d == "169":
        xemu_widescreen_on()
    else:
        xemu_widescreen_off()

def xemu_widescreen_on():
    if system == "linux":
        config_path=f"{home}/.var/app/app.xemu.xemu/config/xemu/xemu.toml"
    if system.startswith("win"):
        config_path=f"{emus_folder}/xemu/xemu.toml"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/xemu/xemu.toml"

    set_config("fit ", " scale_16_9", config_path)

def xemu_widescreen_off():
    if system == "linux":
        config_path=f"{home}/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
    if system.startswith("win"):
        config_path=f"{emus_folder}/xemu/xemu.toml"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/xemu/xemu.toml"

    set_config("fit ", " scale_4_3", config_path)
